import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static const _prefsKey = 'device_imei';

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefsKey);
    if (cached != null && cached.isNotEmpty) return cached;

    final name = await getDeviceName();
    final suffix = const Uuid().v4().substring(0, 8);
    final id = '$name-$suffix';
    await prefs.setString(_prefsKey, id);
    return id;
  }

  static Future<String> getDeviceName() async {
    final plugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        return '${info.manufacturer} ${info.model}';
      }
      if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        return info.name;
      }
      if (Platform.isMacOS) {
        final info = await plugin.macOsInfo;
        return info.computerName;
      }
    } catch (_) {}
    return Platform.operatingSystem;
  }
}
