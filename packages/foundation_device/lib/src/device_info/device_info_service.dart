import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  Future<Map<String, dynamic>> getDeviceSummary() async {
    if (Platform.isAndroid) {
      final a = await _plugin.androidInfo;
      return {
        'platform': 'android',
        'model': a.model,
        'brand': a.brand,
        'device': a.device,
        'sdkInt': a.version.sdkInt,
      };
    }
    if (Platform.isIOS) {
      final i = await _plugin.iosInfo;
      return {
        'platform': 'ios',
        'model': i.utsname.machine,
        'name': i.name,
        'systemVersion': i.systemVersion,
      };
    }
    return {'platform': 'unknown'};
  }
}