import 'dart:developer' as dev;

import '../../data/remote/postgres_service.dart';
import 'booking_watch_service.dart';
import 'credential_store.dart';

/// Programmadaky rol. Bazadaky topar rollara gabat gelýär:
/// sanly_worker / sanly_manager / sanly_admin
enum AppRole { worker, manager, admin }

extension AppRoleX on AppRole {
  String get dbRole => switch (this) {
    AppRole.worker => 'sanly_worker',
    AppRole.manager => 'sanly_manager',
    AppRole.admin => 'sanly_admin',
  };

  /// Işgär diňe öz bronlaryny görýär
  bool get isWorker => this == AppRole.worker;

  /// Hasabatlary we girdejini görüp bilýärmi
  bool get canSeeReports => this != AppRole.worker;

  /// Işgärleri we ulanyjylary dolandyryp bilýärmi
  bool get canManageStaff => this == AppRole.admin;
}

/// Giren adam barada maglumat
class AuthUser {
  /// Bazadaky hasabyň ady (current_user)
  final String username;
  final AppRole role;

  /// Şu hasaba baglanan işgär. Baglanmadyk bolsa `null` —
  /// menejer we administrator işgär bolman biler.
  final int? employeeId;
  final String? employeeName;

  const AuthUser({
    required this.username,
    required this.role,
    this.employeeId,
    this.employeeName,
  });

  /// Ekranda görkezmek üçin at
  String get displayName => employeeName ?? username;
}

/// Giriş ýalňyşlyklary — ekranda dogry habar görkezmek üçin
enum AuthFailure {
  /// Ady ýa paroly ýalňyş
  badCredentials,

  /// Baza elýeterli däl (wifi, kompýuter öçük)
  unreachable,

  /// Giriş dogry, ýöne hasaba hiç rol berilmedik
  noRole,

  /// Beýlekiler
  unknown,
}

class AuthException implements Exception {
  final AuthFailure failure;
  final String details;
  const AuthException(this.failure, this.details);

  @override
  String toString() => 'AuthException($failure): $details';
}

class AuthService {
  AuthService._();

  static AuthUser? _current;
  static AuthUser? get current => _current;
  static bool get isSignedIn => _current != null;

  /// Girýär, roly kesgitleýär we işgäre baglanyşygy tapýar.
  ///
  /// Rol programmada saýlanmaýar — ol bazada haýsy topara girýändigi
  /// bilen kesgitlenýär. Şonuň üçin ony programmadan "üýtgedip" bolmaýar.
  static Future<AuthUser> signIn({
    required String username,
    required String password,
  }) async {
    // Bazadaky hasaplaryň atlary hemişe kiçi harp bilen. Telefonyň
    // klawiaturasy ilkinji harpy uly edip goýberýär — şonuň üçin
    // ady özümiz kiçeldýäris, ýogsam giriş sebäpsiz ret edilýär.
    final login = username.trim().toLowerCase();

    try {
      await PostgresService.signIn(username: login, password: password);
    } catch (e) {
      throw AuthException(_classify(e), e.toString());
    }

    try {
      final role = await _detectRole();
      final employee = await _findEmployee();

      final user = AuthUser(
        username: PostgresService.currentUser ?? login,
        role: role,
        employeeId: employee?.$1,
        employeeName: employee?.$2,
      );
      _current = user;

      // Fon hyzmaty aýry prosesde işleýär — oňa maglumat gerek.
      // Diňe işgär üçin: menejere we administratora fon gözegçiligi
      // gerek däl, olar programmany özleri açýarlar.
      if (role.isWorker && user.employeeId != null) {
        await CredentialStore.save(
          username: login,
          password: password,
          employeeId: user.employeeId,
        );
        await BookingWatchService.start(employeeName: user.displayName);
      }

      dev.log('Auth: ${user.username} signed in as ${role.name}');
      return user;
    } catch (e) {
      // Rol tapylmadyk bolsa birikmäni açyk goýmaly däl
      await PostgresService.signOut();
      if (e is AuthException) rethrow;
      throw AuthException(AuthFailure.unknown, e.toString());
    }
  }

  static Future<void> signOut() async {
    await BookingWatchService.stop();
    await CredentialStore.clear();
    await PostgresService.signOut();
    _current = null;
  }

  /// Iň ýokary rol saýlanýar: administrator > menejer > işgär
  static Future<AppRole> _detectRole() async {
    final res = await PostgresService.query('''
      SELECT r.rolname
      FROM pg_roles r
      WHERE pg_has_role(current_user, r.oid, 'MEMBER')
        AND r.rolname IN ('sanly_admin', 'sanly_manager', 'sanly_worker')
    ''');

    final names = res.map((r) => r.toColumnMap()['rolname'] as String).toSet();
    if (names.contains('sanly_admin')) return AppRole.admin;
    if (names.contains('sanly_manager')) return AppRole.manager;
    if (names.contains('sanly_worker')) return AppRole.worker;

    throw const AuthException(
      AuthFailure.noRole,
      'Hasaba hiç rol berilmedik',
    );
  }

  /// Hasaba baglanan işgäri tapýar. Baglanmadyk bolsa `null`.
  static Future<(int, String)?> _findEmployee() async {
    final res = await PostgresService.query(
      'SELECT id, name FROM employees WHERE lower(db_user) = lower(current_user)',
    );
    if (res.isEmpty) return null;
    final row = res.first.toColumnMap();
    return (row['id'] as int, row['name'] as String);
  }

  static AuthFailure _classify(Object error) {
    final text = error.toString().toLowerCase();
    // 28P01 — parol ýalňyş, 28000 — hasap ýok ýa rugsat ýok
    if (text.contains('28p01') ||
        text.contains('28000') ||
        text.contains('password authentication failed') ||
        text.contains('role') && text.contains('does not exist')) {
      return AuthFailure.badCredentials;
    }
    if (text.contains('timeout') ||
        text.contains('socket') ||
        text.contains('connection refused') ||
        text.contains('failed host lookup') ||
        text.contains('unreachable')) {
      return AuthFailure.unreachable;
    }
    return AuthFailure.unknown;
  }
}
