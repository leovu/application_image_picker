
import 'dart:async';
import 'dart:io';
import 'package:application_image_picker/ulitilites/dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:native_screenshot/native_screenshot.dart';

class CameraAndroidHome extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String title;
  final bool isIDCard;
  final bool previewPlayer;
  final bool isForceFrontCamera;
  final String frame;
  final String warning;
  final String iconCamera;

  CameraAndroidHome(
      {@required this.cameras,
        this.isIDCard,
        this.title,
        this.previewPlayer = false,
        this.isForceFrontCamera = false,
        this.frame,
        this.warning = "",this.iconCamera});
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
  bool isScreenshot = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (controller != null) {
      controller.setFlashMode(FlashMode.off);
    }
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
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.medium,
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

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      if (controller != null &&
          controller.description.lensDirection == CameraLensDirection.front) {
        return;
      }
      if (controller != null) {
        await controller.setFlashMode(mode);
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
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

    setFlashMode(FlashMode.off);
    try {
      XFile file = await controller.takePicture();
      if (widget.previewPlayer) {
        fileImage = await ImageProcessor.crop(file.path,MediaQuery.of(context).size.width,MediaQuery.of(context).size.height);
      } else {
        fileImage = File(file.path);
      }
      List<dynamic> result = [];
      result.add(fileImage);
      bool isCurrentFront =
      controller.description.lensDirection == CameraLensDirection.front
          ? true
          : false;
      result.add(isCurrentFront);
      CustomNavigator().pop(context, object: result);
    } on CameraException catch (_) {
      try {
        setState(() {
          isScreenshot = true;
        });
        await Future.delayed(Duration(seconds: 1));
        String path = await NativeScreenshot.takeScreenshot();
        if(widget.previewPlayer){
          fileImage = await ImageProcessor.crop(path,MediaQuery.of(context).size.width,MediaQuery.of(context).size.height);
        }else{
          fileImage = File(path);
        }
        setState(() {
          isScreenshot = false;
        });
        List<dynamic> result = [];
        result.add(fileImage);
        bool isCurrentFront =
        controller.description.lensDirection == CameraLensDirection.front
            ? true
            : false;
        result.add(isCurrentFront);
        CustomNavigator().pop(context, object: result);
      } catch (e) {
        _showCameraException(e);
        return null;
      }
    }
    return fileImage.path;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  Widget _cameraPreviewWidgetIDCard() {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    } else {
      if(widget.previewPlayer){
        return Container(
          height: MediaQuery.of(context).size.height,
          child: isScreenshot
              ? CameraPreview(
            controller,
          )
              : Stack(
            fit: StackFit.expand,
            alignment: Alignment.topCenter,
            children: <Widget>[
              CustomPaint(
                foregroundPainter: Paint(),
                size: Size.fromHeight(MediaQuery.of(context).size.height),
                child: CameraPreview(
                  controller,
                ),
              ),
              ClipPath(clipper: Clip(), child: CameraPreview(controller))
            ],
          ),
        );
      }
      return CameraPreview(controller);
    }
  }

  Widget _frameCameraIdCard() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: isScreenshot
          ? Container()
          : Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top +
                (MediaQuery.of(context).size.width * 0.05),
          ),
          Row(
            children: [
              Opacity(
                child: InkWell(
                  onTap: () => CustomNavigator().pop(context),
                  child: Container(
                    width: 48.0,
                    height: 48.0,
                    padding: EdgeInsets.only(
                        left: (MediaQuery.of(context).size.width * 0.05)),
                    child: Icon(Icons.close,color: Colors.white,),
                  ),
                ),
                opacity: 1.0,
              )
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.089,
          ),
          if (widget.frame != null)
            Container(
              height: 300,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(widget.frame), fit: BoxFit.fill)),
              // child: Image.asset(Assets.imgFrameIdCard),
            ),
          if (widget.warning != null)
            Text(
              widget.warning,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          Expanded(child: Container()),
          (widget.previewPlayer)
              ? Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(
                MediaQuery.of(context).size.width * 0.05),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? "",
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  height: MediaQuery.of(context).size.width*0.05,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.height * 0.08,
                  child: MaterialButton(
                    child: widget.iconCamera!=null?Image.asset(
                      widget.iconCamera,
                    ): Container(
                      padding: EdgeInsets.all(4.0),
                      decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      width: MediaQuery.of(context).size.height * 0.08,
                      height: MediaQuery.of(context).size.height * 0.08,
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
                )
              ],
            ),
          )
              : _captureControlRowWidget(),
        ],
      ),
    );
  }
  Widget _captureControlRowWidget() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          Center(
            child: MaterialButton(
              child: Icon(
                Icons.camera,
                size: MediaQuery.of(context).size.height * 0.065,
                color: Colors.white,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body:Stack(
          fit: StackFit.expand,
          children: [_cameraPreviewWidgetIDCard(), _frameCameraIdCard()],
        )
    );
  }
}

class Paint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(
      Colors.grey.withOpacity(0.8),
      BlendMode.dstOut,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class Clip extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    final top = size.height - (size.height * 0.8).toInt();
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, top, size.width, size.height  * 0.37),
          Radius.circular(0.0)));
    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}

class ImageProcessor {
  static Future<File> crop(String imagePath, double maxWidth, double maxHeight) async {
    try {
      ImageProperties properties =
      await FlutterNativeImage.getImageProperties(imagePath);
      final height = properties.height;
      final width = properties.width;
      final top = height - (height * 0.8).toInt();
      File croppedFile = await FlutterNativeImage.cropImage(imagePath, (top * 1.5).round(), 0, (width * 0.37).round(), height);
      return croppedFile;
    } catch (e) {
      print(e);
      File compressedFile = await FlutterNativeImage.compressImage(imagePath,
          quality: 100,
          targetWidth:maxWidth.round(),
          targetHeight:maxHeight.round());
      ImageProperties properties =
      await FlutterNativeImage.getImageProperties(compressedFile.path);
      final height = properties.height;
      final width = properties.width;
      final top = height - (height * 0.8).toInt();
      File croppedFile = await FlutterNativeImage.cropImage(imagePath, (width * 0.2).round(), (top * 3.5).round(), (width * 2.5).round(), (height * 0.8).round());
      return croppedFile;
    }
  }
}
