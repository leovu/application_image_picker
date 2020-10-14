import 'dart:async';
import 'dart:io';
import 'package:application_image_picker/application_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ulitilites/permission_request.dart';

class RetroPermissionHandler {
  static Future<bool> requestPermission(PermissionRequestType type) async {
    if (Platform.isAndroid) {
      if (await Permission.location.isPermanentlyDenied) {
        await openAppSettings();
        PermissionStatus permission = await _checkPermission(type);
        if (permission == PermissionStatus.granted) {
          return true;
        }
        return false;
      } else {
        PermissionStatus permission = await _checkPermission(type);
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return await request(type);
        }
      }
    } else {
      PermissionStatus permission = await _checkPermission(type);
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
        PermissionStatus permission = await _checkPermission(type);
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          PermissionStatus permission = await _checkPermission(type);
          if (permission == PermissionStatus.granted) {
            return true;
          }
        }
        return false;
      }
    }
  }

  static Future<bool> checkPermission(PermissionRequestType type) async {
    switch (type) {
      case PermissionRequestType.CAMERA:
        PermissionStatus permission = await Permission.camera.status;
        if (permission == PermissionStatus.granted) {
          return true;
        }
        return false;
        break;
      case PermissionRequestType.LOCATION:
        PermissionStatus permission = await Permission.location.status;
        if (permission == PermissionStatus.granted) {
          return true;
        }
        return false;
        break;
      case PermissionRequestType.RECORD_AUDIO:
        PermissionStatus permission = await Permission.microphone.status;
        if (permission == PermissionStatus.granted) {
          return true;
        }
        return false;
        break;
      case PermissionRequestType.STORAGE:
        if (Platform.isIOS) {
          PermissionStatus permission = await Permission.photos.status;
          if (permission == PermissionStatus.granted) {
            return true;
          }
          return false;
        } else {
          PermissionStatus permission = await Permission.storage.status;
          if (permission == PermissionStatus.granted) {
            return true;
          }
          return false;
        }
        break;
      default:
        return false;
        break;
    }
  }

  static Future<PermissionStatus> _checkPermission(
      PermissionRequestType type) async {
    switch (type) {
      case PermissionRequestType.CAMERA:
        PermissionStatus permission = await Permission.camera.status;
        return permission;
        break;
      case PermissionRequestType.LOCATION:
        PermissionStatus permission = await Permission.location.status;
        return permission;
        break;
      case PermissionRequestType.RECORD_AUDIO:
        PermissionStatus permission = await Permission.microphone.status;
        return permission;
        break;
      case PermissionRequestType.STORAGE:
        if (Platform.isIOS) {
          PermissionStatus permission = await Permission.photos.status;
          return permission;
        } else {
          PermissionStatus permission = await Permission.storage.status;
          return permission;
        }
        break;
      default:
        return null;
        break;
    }
  }

  static Future<bool> request(PermissionRequestType type) async {
    final channel = MethodChannel("flutter.io/requestPermission");
    bool event = false;
    int result = 0;

    try {
      if (type == PermissionRequestType.CAMERA) {
        result = await channel.invokeMethod<int>('camera');
      } else if (type == PermissionRequestType.LOCATION) {
        result = await channel.invokeMethod<int>('location');
      } else if (type == PermissionRequestType.RECORD_AUDIO) {
        result = await channel.invokeMethod<int>('record_audio');
      } else if (type == PermissionRequestType.STORAGE) {
        if (Platform.isAndroid) {
          result = await channel.invokeMethod<int>('storage');
        } else
          result = 1;
      }
    } catch (e) {
      print(e);
    }
    if (result == -1)
      await openAppSettings();
    else if (result == 1) event = true;
    return event;
  }
}
