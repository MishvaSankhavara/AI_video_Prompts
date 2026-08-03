import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  static void print(String? message) {
    printLog(message);
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      fontSize: 16.0,
    );
  }
}
