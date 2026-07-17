import 'package:shared_preferences/shared_preferences.dart';

/// Central wrapper around [SharedPreferences].
///
/// Keep all persisted-preference reads/writes here — screens should call these
/// methods instead of touching `SharedPreferences` directly.
class SharedPrefs {
  SharedPrefs._();

  // Keys
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  // ── Onboarding ───────────────────────────────────────────────────────────

  /// Whether the user has already completed the onboarding flow.
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  /// Marks onboarding as completed.
  static Future<void> setOnboardingSeen() async {
    final prefs = await _prefs;
    await prefs.setBool(_keyHasSeenOnboarding, true);
  }

  // ── Subscription ──────────────────────────────────────────────────────────

  static const String _keyIsSubscribed = 'is_subscribed';
  static const String _keyExpiryDate = 'subscription_expiry_date';

  static Future<bool> isSubscribed() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyIsSubscribed) ?? false;
  }

  static Future<void> setSubscribed(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyIsSubscribed, value);
  }

  static Future<String?> getExpiryDate() async {
    final prefs = await _prefs;
    return prefs.getString(_keyExpiryDate);
  }

  static Future<void> setExpiryDate(String dateIso) async {
    final prefs = await _prefs;
    await prefs.setString(_keyExpiryDate, dateIso);
  }
}
