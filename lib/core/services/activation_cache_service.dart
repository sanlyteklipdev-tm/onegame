import 'package:shared_preferences/shared_preferences.dart';

import 'activation_api_service.dart';
import 'device_id_service.dart';

class ActivationCacheService {
  static const _key = 'is_active';

  static Future<void> setIsActive(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  /// Öň ýatda saklanan `is_active` ýagdaýy. Entek hiç haçan barlanmadyk bolsa null.
  static Future<bool?> getCachedIsActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key);
  }
}

/// Enjamyň ýagdaýyny serwerden barlaýar we netijäni SharedPreferences-de saklaýar.
/// Internet ýok bolsa [NoInternetException], enjam bellige alynmadyk bolsa
/// [DeviceNotRegisteredException] atýar.
Future<DeviceActivationStatus> checkAndCacheActivation(
  ActivationApiService api,
) async {
  final deviceImei = await DeviceIdService.getDeviceId();
  final status = await api.checkDeviceStatus(deviceImei);
  await ActivationCacheService.setIsActive(
    status == DeviceActivationStatus.active,
  );
  return status;
}
