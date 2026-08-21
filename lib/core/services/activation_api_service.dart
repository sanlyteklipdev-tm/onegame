import 'package:dio/dio.dart';

class ApiConfig {
  static const String baseUrl = 'http://216.250.13.114:3001';
}

class WrongCredentialsException implements Exception {}

class DeviceNotRegisteredException implements Exception {}

class ApiRequestException implements Exception {
  final String message;
  ApiRequestException(this.message);
}

enum DeviceActivationStatus { active, pending }

class ActivationApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/app/login',
        data: {'username': username, 'password': password},
      );
      return response.data['token'] as String;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw WrongCredentialsException();
      }
      throw ApiRequestException(_messageFor(e));
    }
  }

  Future<void> registerDevice({
    required String token,
    required String deviceImei,
    required String shopName,
    required String descriptionMain,
    required String description,
  }) async {
    try {
      await _dio.post(
        '/api/devices/register',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'device_imei': deviceImei,
          'shop_name': shopName,
          'description_main': descriptionMain,
          'description': description,
        },
      );
    } on DioException catch (e) {
      throw ApiRequestException(_messageFor(e));
    }
  }

  Future<DeviceActivationStatus> checkDeviceStatus(String deviceImei) async {
    try {
      final response = await _dio.get('/api/devices/status/$deviceImei');
      final isActive = response.data['is_active'] == true;
      return isActive
          ? DeviceActivationStatus.active
          : DeviceActivationStatus.pending;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw DeviceNotRegisteredException();
      }
      throw ApiRequestException(_messageFor(e));
    }
  }

  String _messageFor(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Serwer bilen baglanyşyk ýok. Internedi barlaň.';
    }
    return 'Näbelli ýalňyşlyk ýüze çykdy.';
  }
}
