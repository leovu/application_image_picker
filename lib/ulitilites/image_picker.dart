import 'dart:io';
import 'package:android_gallery_picker/android_gallery_picker.dart';
import 'package:application_image_picker/application_platform.dart';
import 'package:application_image_picker/camera/custom_camera.dart';
import 'package:application_image_picker/ulitilites/constant.dart';
import 'package:application_image_picker/ulitilites/dialog.dart';
import 'package:application_image_picker/ulitilites/permission_request.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ApplicationImagePicker {
  static Future<File> pickImage(BuildContext context,
      {@required ImageSource source,
      double maxWidth,
      double maxHeight,
      int imageQuality,
      String appBarColor,
      String titleAppBar,bool isPreviewPlayer}) async {
    assert(source != null);
    try {
      bool permission = false;
      if (source == ImageSource.camera) {
        permission = await cameraPermission(context);
      } else {
        if (ApplicationPlatform.isAndroid) {
          permission = await storagePermission(context);
        } else {
          permission = true;
        }
      }
      if (!permission) return null;
    } catch (_) {
      return null;
    }
    if (source == ImageSource.camera && Platform.isAndroid) {
      List<CameraDescription> cameras = [];
      cameras = await availableCameras();
      if (cameras == null || cameras.length == 0) {
        openAlertDialog(
            context, Common.stringNotification, Common.stringAlertCamera);
        return null;
      }
      Future.delayed(Duration(seconds: 2));
      List<dynamic> resultCamera = await CustomNavigator().push(context,
          CameraAndroidHome(cameras: cameras, isForceFrontCamera: false,previewPlayer: false,));
      if (resultCamera == null) {
        return null;
      }
      if (resultCamera.length == null) {
        return null;
      }
      if (resultCamera.length == 0) {
        return null;
      }
      File image = resultCamera[0];
      File file = File(image.path);
      return compressImage(file);
    } else if (source == ImageSource.gallery && Platform.isAndroid) {
      print(titleAppBar);
      String event = await MethodChannel("flutter.io/gallery")
          .invokeMethod<String>('gallery', {
        "multiPick": "false",
        "colorAppBar": appBarColor ?? "#000000",
        "titleAppBar": titleAppBar ?? "",
        "limitMultiPick": "1"
      });
      if (event == null) return null;
      return File(event);
    } else {
      final picker = ImagePicker();
      final _image = await picker.getImage(
          source: source,
          maxHeight: 2450,
          maxWidth: 1750,
          imageQuality: imageQuality);
      if (_image != null && _image.path != null) {
        return compressImage(File(_image.path));
      } else {
        return null;
      }
    }
  }

  static Future<List<File>> pickImages(BuildContext context,
      { double maxWidth,
        double maxHeight,
        int imageQuality,
        String appBarColor,
        String titleAppBar,
        int limitMultiPick}) async {
    try {
      bool permission = false;
      if (ApplicationPlatform.isAndroid) {
        permission = await storagePermission(context);
      } else {
        permission = true;
      }
      if (!permission) return null;
    } catch (_) {
      return null;
    }
    if (Platform.isAndroid) {
      List<File> images = await AndroidGalleryPicker.images(colorAppBar:appBarColor,
          titleAppBar:titleAppBar, limitMultiPick:limitMultiPick);
      return images;
    } else {
      List<dynamic> event = await MethodChannel("flutter.io/gallery")
          .invokeMethod<List<dynamic>>('gallery', {
        "limitMultiPick": (limitMultiPick ?? 3).toString()
      });
      if (event == null) return null;
      List<File> _arr = [];
      if (event.length > 0) {
        event.forEach((element)  {
          String url = element;
          url = url.replaceAll("file:///", "/private/");
          File file = File(url);
          _arr.add(file);
        });
        return _arr;
      }
      else {
        return null;
      }
    }
  }

  static Future<File> compressImage(File imageFile) async {
    File compressedFile;
    var length = await imageFile.length();
    if (length > 1045504) {
      compressedFile =
          await FlutterNativeImage.compressImage(imageFile.path, quality: 80);
      length = await compressedFile.length();
      if (length > 1045504) {
        compressedFile =
            await FlutterNativeImage.compressImage(imageFile.path, quality: 60);
        length = await compressedFile.length();
      } else {
        if (length > 1045504) {
          compressedFile = await FlutterNativeImage.compressImage(
              imageFile.path,
              quality: 40);
          length = await compressedFile.length();
        } else {
          compressedFile = await FlutterNativeImage.compressImage(
              imageFile.path,
              quality: 20);
          length = await compressedFile.length();
        }
      }
    } else {
      compressedFile = imageFile;
    }
    return compressedFile;
  }

  static Future<bool> cameraPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      if (await Permission.camera.isPermanentlyDenied) {
        await openAppSettings();
        PermissionStatus permission = await Permission.camera.status;
        if (permission == PermissionStatus.granted) {
          return true;
        }
        return false;
      } else {
        PermissionStatus permission = await Permission.camera.status;
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return await PermissionRequest.request(PermissionRequestType.CAMERA);
        }
      }
    } else {
      PermissionStatus permission = await Permission.camera.status;
      if (permission == PermissionStatus.granted) {
        return true;
      } else if (permission == PermissionStatus.restricted ||
          permission == PermissionStatus.denied) {
        await openAppSettings();
        if (permission == PermissionStatus.granted) {
          return true;
        }
        return false;
      } else {
        PermissionStatus permission = await Permission.camera.status;
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          PermissionStatus permission = await Permission.camera.request();
          if (permission == PermissionStatus.granted) {
            return true;
          }
        }
        return false;
      }
    }
  }

  static Future<bool> storagePermission(BuildContext context) async {
    if (await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
      PermissionStatus permission = await Permission.storage.status;
      if (permission == PermissionStatus.granted) {
        return true;
      }
      return false;
    } else {
      PermissionStatus permission = await Permission.storage.status;
      if (permission == PermissionStatus.granted) {
        return true;
      } else {
        return await PermissionRequest.request(PermissionRequestType.STORAGE);
      }
    }
  }
}
