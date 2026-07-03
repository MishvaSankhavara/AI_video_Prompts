import 'package:firebase_database/firebase_database.dart';
import '../device_id_service.dart';
import '../../utils/common_utils.dart';

class FeedbackFirebaseService {
  static final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

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
}
