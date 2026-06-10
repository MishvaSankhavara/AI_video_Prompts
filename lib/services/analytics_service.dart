import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// A wrapper service around [FirebaseAnalytics] to centralize event tracking.
class AnalyticsService {
  AnalyticsService._internal();

  /// Singleton instance of the analytics service.
  static final AnalyticsService instance = AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Expose the observer to be optional for navigation system if routing tracking is needed.
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  /// Sets user properties to segment analytics reports (e.g. user preferences).
  Future<void> setUserProperty({required String name, required String value}) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      debugPrint('Analytics: User Property Set [$name = $value]');
    } catch (e) {
      debugPrint('Analytics Error setting user property: $e');
    }
  }

  /// Logs custom event with optional parameters.
  Future<void> logEvent({required String name, Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('Analytics: Event Logged [$name] with parameters: $parameters');
    } catch (e) {
      debugPrint('Analytics Error logging event $name: $e');
    }
  }

  /// Logs a screen view explicitly. Recommended over observers for nested page views.
  Future<void> logScreenView({required String screenName, String? screenClass}) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('Analytics: Screen View Logged [$screenName]');
    } catch (e) {
      debugPrint('Analytics Error logging screen view $screenName: $e');
    }
  }
}
