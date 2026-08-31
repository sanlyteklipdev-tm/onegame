import 'package:shared_preferences/shared_preferences.dart';

import 'device_id_service.dart';

/// Enjamyň ady — ýazgylarda "haýsy enjamdan goşuldy" diýip görkezmek üçin.
///
/// Her enjamda öz ady saklanýar (SharedPreferences), sazlamalardan
/// üýtgedilip bilner: «Kassa», «Serdaryň telefony», «Zalyň planşeti».
class DeviceNameService {
  DeviceNameService._();

  static const _key = 'device_name';
  static String _cached = '';

  /// Repositoryler ýazan wagty sinhron gerek bolýar, şonuň üçin
  /// programma açylanda [load] bilen öňünden okalýar.
  static String get current => _cached;

  /// Programma başlanda bir gezek çagyrylýar
  static Future<String> load() async {
    final prefs = await SharedPreferences.getInstance();
    var name = prefs.getString(_key);

    if (name == null || name.trim().isEmpty) {
      // Ilkinji gezek — enjamyň öz ady goýulýar, soň üýtgedip bolýar
      name = await DeviceIdService.getDeviceName();
      await prefs.setString(_key, name);
    }

    _cached = name;
    return name;
  }

  static Future<void> setName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, trimmed);
    _cached = trimmed;
  }
}
