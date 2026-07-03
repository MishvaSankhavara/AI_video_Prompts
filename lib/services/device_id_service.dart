import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import '../utils/common_utils.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<String?> getDeviceId() async {
    try {
      if (Platform.isIOS) {
        var iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor;
      } else if (Platform.isAndroid) {
        const androidIdPlugin = AndroidId();
        return await androidIdPlugin.getId();
      }
    } catch (e) {
      CommonUtils.printLog('>>> DEVICE ID ERROR: $e');
      return null;
    }
    return null;
  }

  static String getDeviceOs() {
    if (Platform.isIOS) {
      return 'IOS';
    } else if (Platform.isAndroid) {
      return 'Android';
    }
    return 'Other';
  }
}
