import 'dart:io';

class RootDetection {
  static Future<bool> isDeviceCompromised() async {
    if (Platform.isAndroid) {
      return _checkAndroid();
    }
    if (Platform.isIOS) {
      return _checkIOS();
    }
    return false;
  }

  static Future<bool> _checkAndroid() async {
    const paths = [
      '/system/app/Superuser.apk',
      '/system/xbin/su',
      '/system/bin/su',
    ];
    return paths.any((p) => File(p).existsSync());
  }

  static Future<bool> _checkIOS() async {
    const paths = [
      '/Applications/Cydia.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
    ];
    return paths.any((p) => File(p).existsSync());
  }
}