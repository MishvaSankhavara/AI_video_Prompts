import 'dart:developer';
import 'package:flutter/foundation.dart';

class CommonUtils {
  static void printLog(String? message) {
    if (kDebugMode) {
      if (message != null && message.isNotEmpty) {
        log(message);
      } else {
        log('[Empty or Null Log]');
      }
    }
  }
}
