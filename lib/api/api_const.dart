import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../services/firebase/firebase_service.dart';
import '../utils/common_utils.dart';

/// Centralized API configuration: base URL, auth token and endpoint paths.
class ApiConst {
  ApiConst._();

  // Base
  // static String baseUrl = 'https://ai-prompt.3ftechnolabs.com/api/v1/ngd';
  static String baseUrl = '';
  static const String authToken = r'x.NF#f25G),Ew55J8HnwsXGQ}2j%N4F5[.DHyJkG4R$HP@;2LOF5kz!Ovex,X.X6)dr6s3fniU}o@3)zFVyNN$2Akx)2=t+qlEbk';
  
  // Endpoints
  static const String getAiVideoCategories = '/getAiVideoCategories';
  static const String getAiVideoByCategoryId = '/getAiVideoByCategoryId';

  static Future<void> applyServerConfig(FirebaseRemoteConfig remoteConfig) async {
    String apiMode       = remoteConfig.getString("api_mode");
    String primaryUrl    = remoteConfig.getString("primary_url");
    String backupUrl     = remoteConfig.getString("backup_url");
    String forcedUrl     = remoteConfig.getString("forced_url");
    String percentageUrl = remoteConfig.getString("percentage_url");

    CommonUtils.printLog('--- Server Config Loaded ---');
    CommonUtils.printLog('api_mode: $apiMode');
    CommonUtils.printLog('primary_url: $primaryUrl');
    CommonUtils.printLog('backup_url: $backupUrl');
    CommonUtils.printLog('forced_url: $forcedUrl');
    CommonUtils.printLog('percentage_url: $percentageUrl');

    String selectedUrlType = 'unknown';

    switch (apiMode) {
      case "failover":
        bool alive = await FirebaseService.failover("${primaryUrl}/test-api");
        // bool alive = await FirebaseService.failover("${primaryUrl}");
        baseUrl = alive ? primaryUrl : backupUrl;
        selectedUrlType = alive ? 'primary (via failover check passed)' : 'backup (via failover check failed)';
        break;

      case "primary_url":
        baseUrl = primaryUrl;
        selectedUrlType = 'primary';
        break;

      case "backup_url":
        baseUrl = backupUrl;
        selectedUrlType = 'backup';
        break;

      case "forced_url":
        baseUrl = forcedUrl;
        selectedUrlType = 'forced';
        break;

      case "percentage_url":
        baseUrl = percentageUrl;
        selectedUrlType = 'percentage';
        break;

      default:
        selectedUrlType = 'default/none';
        break;
    }

    CommonUtils.printLog('Selected URL Type: $selectedUrlType');
    CommonUtils.printLog('Final baseUrl set to: $baseUrl');
    CommonUtils.printLog('--------------------------');
  }
}
