import 'dart:io';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../utils/common_utils.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static const MethodChannel _channel = MethodChannel('com.aivideoprompt/device_id');

  static Future<String?> getDeviceId() async {
    try {
      if (Platform.isIOS) {
        try {
          final String? persistentId = await _channel.invokeMethod<String>('getPersistentDeviceId');
          if (persistentId != null && persistentId.isNotEmpty) {
            return persistentId;
          }
        } catch (e) {
          CommonUtils.printLog('>>> PERSISTENT DEVICE ID METHOD CHANNEL ERROR: $e');
        }
        var iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor;
      } else if (Platform.isAndroid) {
        var androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id;
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
