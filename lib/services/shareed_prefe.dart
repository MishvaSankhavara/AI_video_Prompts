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
}
