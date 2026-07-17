import 'package:flutter/foundation.dart';

class AppConstants {
  static const String weeklySubscriptionId = 'ai_video_prompts_weekly';
  static const String yearlySubscriptionId = 'ai_video_prompts_yearly';
  
  static final ValueNotifier<bool> isSubscribedNotifier = ValueNotifier<bool>(false);
  
  static bool get isSubscribed => isSubscribedNotifier.value;
  static set isSubscribed(bool value) => isSubscribedNotifier.value = value;
}
