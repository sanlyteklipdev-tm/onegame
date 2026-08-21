import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static const _prefsKey = 'device_imei';

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefsKey);
    if (cached != null && cached.isNotEmpty) return cached;

    final id = const Uuid().v4();
    await prefs.setString(_prefsKey, id);
    return id;
  }
}
