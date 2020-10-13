import 'dart:async';
import 'dart:io';
import 'package:application_image_picker/permission_request.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class RetroLocationRequest {
  static Future<bool> openLocationRequest(BuildContext context,
      {String strConfirm,
        String strNotification,
        String strAlertCamera,
        String strSelectGallery,
        String strTakePhoto,
        String appBarColor,
        String titleAppBar}) async {
    bool check = await locationPermission(context);
    if (check != null){
      return check;
    }
    return null;
  }


  static Future<bool> locationPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      if (await Permission.location.isPermanentlyDenied) {
        await openAppSettings();
        PermissionStatus permission = await Permission.camera.status;
        if (permission == PermissionStatus.granted) {
          return true;
        }
        return false;
      } else {
        PermissionStatus permission = await Permission.location.status;
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return await PermissionRequest.request(PermissionRequestType.LOCATION);
        }
      }
    } else {
      PermissionStatus permission = await Permission.location.status;
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
        PermissionStatus permission = await Permission.location.status;
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
}
