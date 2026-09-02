import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_service.dart';

/// Giren adam. Girilmedik bolsa `null`.
class AuthNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => AuthService.current;

  Future<AuthUser> signIn({
    required String username,
    required String password,
  }) async {
    final user = await AuthService.signIn(
      username: username,
      password: password,
    );
    state = user;
    return user;
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthUser?>(
  AuthNotifier.new,
);

/// Häzirki rol. Girilmedik bolsa `null` —
/// menýu we ekranlar şuňa görä gurulýar.
final currentRoleProvider = Provider<AppRole?>(
  (ref) => ref.watch(authProvider)?.role,
);

/// Giren işgäriň id-si. Işgäre baglanmadyk hasapda `null`.
/// Işgäriň bronlaryny süzmek üçin ulanylýar.
final currentEmployeeIdProvider = Provider<int?>(
  (ref) => ref.watch(authProvider)?.employeeId,
);
