import 'package:firebase_database/firebase_database.dart';
import '../device_id_service.dart';
import '../../utils/common_utils.dart';
import '../../api/api_const.dart';
import 'package:http/http.dart' as http;

class FirebaseService {
  static final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  static Future<bool> failover(String url) async {
    CommonUtils.printLog("====ServerConfig - Primary url check with GET method: $url");

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer ${ApiConst.authToken}',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      CommonUtils.printLog(
          "====ServerConfig - test-api HTTP response code: ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      CommonUtils.printLog(
          "====ServerConfig - test-api request failed: $e");
      return false;
    }
  }

  static Future<bool> submitFeedback(String feedbackText) async {
    try {
      String? deviceId = await DeviceInfoService.getDeviceId();
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = 'unknown_device';
      }
      
      // Sanitize deviceId because Firebase paths cannot contain ., #, $, [, or ]
      deviceId = deviceId.replaceAll(RegExp(r'[.#$\[\]]'), '_');
      
      String osType = DeviceInfoService.getDeviceOs();
      String osNode = osType == 'IOS' ? 'IOS feedbacks' : 'Android feedbacks';

      // Path: feedbacks/<osNode>/<device_id>
      DatabaseReference feedbackRef = _dbRef
          .child('feedbacks')
          .child(osNode)
          .child(deviceId);

      // Create or overwrite entry directly under device ID
      await feedbackRef.set({
        'feedback': feedbackText,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      return true;
    } catch (e, stacktrace) {
      CommonUtils.printLog('>>> FEEDBACK SUBMISSION ERROR: $e\n$stacktrace');
      return false;
    }
  }

  static Future<void> storeSubscriptionDetails({
    required String productId,
    required String purchaseId,
    required String purchaseTime,
  }) async {
    try {
      String? deviceId = await DeviceInfoService.getDeviceId();
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = 'unknown_device';
      }
      
      deviceId = deviceId.replaceAll(RegExp(r'[.#$\[\]]'), '_');
      
      String osType = DeviceInfoService.getDeviceOs();
      String osNode = osType == 'IOS' ? 'ios' : 'android';

      String subscriptionType = 'weekly';
      if (productId.toLowerCase().contains('yearly') || productId.toLowerCase().contains('annual')) {
        subscriptionType = 'yearly';
      }

      DatabaseReference subscriptionRef = _dbRef
          .child(osNode)
          .child(deviceId)
          .child('subscription');

      await subscriptionRef.set({
        'productId': productId,
        'purchaseId': purchaseId,
        'purchaseTime': purchaseTime,
        'subscriptionType': subscriptionType,
      });

    } catch (e, stacktrace) {
      CommonUtils.printLog('>>> SUBSCRIPTION STORE ERROR: $e\n$stacktrace');
    }
  }
}
