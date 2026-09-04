import 'dart:developer' as dev;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Giren adamyň maglumatlaryny enjamda gorag bilen saklaýar.
///
/// Näme üçin gerek: fon hyzmaty aýry prosesde işleýär we baza öz
/// başyna birigýär — şonuň üçin oňa at we parol gerek.
///
/// Howpsuzlyk barada: bu adamyň öz paroly, öz telefonynda. Işgäriň
/// hasaby diňe öz bronlaryny görýär — hasabatlara we girdejä hukugy
/// ýok. Öňki howp başgady: APK-nyň içinde hemmä bir umumy parol
/// ýatyrdy, indi beýle däl.
///
/// Android-de maglumat şifrlenip saklanýar — enjamyň açary bilen,
/// başga programma okap bilmeýär.
class CredentialStore {
  CredentialStore._();

  static const _storage = FlutterSecureStorage();

  static const _kUser = 'sanly_username';
  static const _kPass = 'sanly_password';
  static const _kEmployee = 'sanly_employee_id';

  static Future<void> save({
    required String username,
    required String password,
    int? employeeId,
  }) async {
    try {
      await _storage.write(key: _kUser, value: username);
      await _storage.write(key: _kPass, value: password);
      await _storage.write(key: _kEmployee, value: employeeId?.toString());
    } catch (e) {
      // Ýazylmasa-da programma işlemegini dowam etsin,
      // diňe fon hyzmaty işlemez
      dev.log('CredentialStore save failed: $e');
    }
  }

  static Future<({String username, String password, int? employeeId})?>
  read() async {
    try {
      final user = await _storage.read(key: _kUser);
      final pass = await _storage.read(key: _kPass);
      if (user == null || pass == null) return null;

      final emp = await _storage.read(key: _kEmployee);
      return (
        username: user,
        password: pass,
        employeeId: emp == null ? null : int.tryParse(emp),
      );
    } catch (e) {
      dev.log('CredentialStore read failed: $e');
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      await _storage.delete(key: _kUser);
      await _storage.delete(key: _kPass);
      await _storage.delete(key: _kEmployee);
    } catch (e) {
      dev.log('CredentialStore clear failed: $e');
    }
  }
}
