import 'dart:async';
import 'dart:io';
import 'package:application_image_picker/ulitilites/dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraAndroidHome extends StatefulWidget {
  final List<CameraDescription> cameras;
  final bool isForceFrontCamera;
  CameraAndroidHome({@required this.cameras, this.isForceFrontCamera = false});
  @override
  _State createState() {
    return _State();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _State extends State<CameraAndroidHome> with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setCamera();
    });
  }

  void setCamera() {
    if (widget.cameras.length > 0) {
      CameraDescription camDesc;
      if (widget.isForceFrontCamera) {
        for (int i = 0; i <= widget.cameras.length - 1; i++) {
          if (widget.cameras[i].lensDirection == CameraLensDirection.front) {
            camDesc = widget.cameras[i];
            break;
          }
        }
        if (camDesc == null) camDesc = widget.cameras.first;
      } else {
        for (int i = 0; i <= widget.cameras.length - 1; i++) {
          if (widget.cameras[i].lensDirection == CameraLensDirection.back) {
            camDesc = widget.cameras[i];
            break;
          }
        }
        if (camDesc == null) camDesc = widget.cameras.first;
      }
      onNewCameraSelected(camDesc);
    }
  }

  void rotateCamera() {
    if (widget.cameras.length > 0) {
      CameraDescription camDesc;
      for (int i = 0; i <= widget.cameras.length - 1; i++) {
        if (widget.cameras[i].lensDirection !=
            controller.description.lensDirection) {
          if (widget.cameras[i].lensDirection == CameraLensDirection.back ||
              widget.cameras[i].lensDirection == CameraLensDirection.front) {
            camDesc = widget.cameras[i];
            break;
          }
        }
      }
      if (camDesc == null) camDesc = widget.cameras.first;
      onNewCameraSelected(camDesc);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (controller != null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      if (controller != null) {
        controller.dispose();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          'Camera',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
                color: Colors.black,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0,top: 8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: _captureControlRowWidget(),
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    } else {
      return CameraPreview(controller);
    }
  }

  Widget _captureControlRowWidget() {
    return Stack(
      children: <Widget>[
        Center(
          child: MaterialButton(
            child: Container(
              padding: EdgeInsets.all(4.0),
              decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              width: MediaQuery.of(context).size.height * 0.065,
              height: MediaQuery.of(context).size.height * 0.065,
              child: Container(
                padding: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.0)),
              ),
            ),
            onPressed: controller != null &&
                controller.value.isInitialized &&
                !controller.value.isRecordingVideo
                ? onTakePictureButtonPressed
                : null,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.05,
                top: (MediaQuery.of(context).size.height * 0.065) / 8),
            child: IconButton(
              icon: Icon(
                Icons.crop_rotate,
                color: Colors.white,
                size: MediaQuery.of(context).size.height * 0.065 / 2,
              ),
              onPressed: () {
                if (controller != null) {
                  rotateCamera();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.max,
        enableAudio: false);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    File fileImage;
    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await controller.takePicture();
      fileImage = File(file.path);
      List<dynamic> result = [];
      result.add(file);
      bool isCurrentFront =
      controller.description.lensDirection == CameraLensDirection.front
          ? true
          : false;
      result.add(isCurrentFront);
      CustomNavigator().pop(context, object: result);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return fileImage.path;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
