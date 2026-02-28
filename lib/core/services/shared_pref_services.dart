import 'package:camera_app/features/capture/models/session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefServices {
  static const _lastSessionKey = "last_session";
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  /// Save Last Session
  static Future<void> saveLastSession(SessionModel session) async {
    await _prefs.setString(_lastSessionKey, session.toJson());
  }

  /// Get Last Session
  static Future<SessionModel?> getLastSession() async {
    final data = await _prefs.getString(_lastSessionKey);

    if (data == null) return null;

    return SessionModel.fromJson(data);
  }

  /// Clear Last Session (Optional)
  static Future<void> clearLastSession() async {
    await _prefs.remove(_lastSessionKey);
  }
}
