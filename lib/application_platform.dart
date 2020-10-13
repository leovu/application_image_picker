import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApplicationPlatform {
  static final ApplicationPlatform _shared =
  new ApplicationPlatform._internal();
  static ApplicationPlatform get shared => _shared;
  static bool get isIOS => _isWeb() ? false : Platform.isIOS;
  static bool get isAndroid => _isWeb() ? false : Platform.isAndroid;
  static bool get isWeb => _isWeb();
  factory ApplicationPlatform() {
    return _shared;
  }
  ApplicationPlatform._internal();

  static bool _isWeb() {
    return kIsWeb;
  }
}

