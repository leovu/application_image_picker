import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequest {
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

  static Future<bool> check(PermissionRequestType type) async {
    final channel = MethodChannel("flutter.io/checkPermission");
    int result = 0;
    try {
      if (type == PermissionRequestType.CAMERA) {
        result = await channel.invokeMethod<int>('camera');
      } else if (type == PermissionRequestType.LOCATION) {
        result = await channel.invokeMethod<int>('location');
      } else if (type == PermissionRequestType.RECORD_AUDIO) {
        result = await channel.invokeMethod<int>('record_audio');
      } else if (type == PermissionRequestType.STORAGE) {
        result = await channel.invokeMethod<int>('storage');
      }
    } catch (e) {
      print(e);
    }
    return result == 1 ? true : false;
  }
}

enum PermissionRequestType { CAMERA, LOCATION, RECORD_AUDIO, STORAGE }
enum PermissionResult { GRANTED, DENIED, NEVER_ASK_AGAIN }
