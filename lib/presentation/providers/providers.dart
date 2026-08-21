import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../core/l10n/app_localizations.dart';

import '../../data/local/isar_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/models/player_session_model.dart';
import '../../data/models/table_model.dart';
import '../../data/models/history_log_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/table_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/price_calculator.dart';
import '../../core/services/activation_api_service.dart';

// ════════════════════════════════════════════════════════════
//  REPOSITORY PROVIDERS
// ════════════════════════════════════════════════════════════

final tableRepositoryProvider = Provider<TableRepository>(
  (ref) => IsarTableRepository(),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => IsarSessionRepository(),
);

final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => IsarCustomerRepository(),
);

// ════════════════════════════════════════════════════════════
//  CUSTOMER PROVIDERS
// ════════════════════════════════════════════════════════════

final customersStreamProvider = StreamProvider<List<CustomerModel>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.watchAll();
});

class CustomerNotifier extends AsyncNotifier<void> {
  CustomerRepository get _repo => ref.read(customerRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<void> saveCustomer(CustomerModel customer) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.save(customer).then((_) {}));
  }

  Future<void> deleteCustomer(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.delete(id));
  }
}

final customerNotifierProvider = AsyncNotifierProvider<CustomerNotifier, void>(
  CustomerNotifier.new,
);

// ════════════════════════════════════════════════════════════
//  TIMER PROVIDER — Her sekuntda emitter (real-time timer üçin)
// ════════════════════════════════════════════════════════════

final timerProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

// ════════════════════════════════════════════════════════════
//  TABLE PROVIDERS
// ════════════════════════════════════════════════════════════

/// Ähli stollaryň reaktiw stream-i
final tablesStreamProvider = StreamProvider<List<TableModel>>((ref) {
  final repo = ref.watch(tableRepositoryProvider);
  return repo.watchAllTables();
});

/// Stol CRUD notifier-i
class TableNotifier extends AsyncNotifier<void> {
  TableRepository get _repo => ref.read(tableRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<void> createTable({
    required String name,
    required double pricePerHour,
    int? maxUsers,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final table = TableModel.create(
        name: name,
        pricePerHour: pricePerHour,
        maxUsers: maxUsers,
      );
      await _repo.createTable(table);
    });
  }

  Future<void> updateTable(TableModel table) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.updateTable(table));
  }

  Future<void> deleteTable(int tableId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.deleteTable(tableId));
  }
}

final tableNotifierProvider = AsyncNotifierProvider<TableNotifier, void>(
  TableNotifier.new,
);

// ════════════════════════════════════════════════════════════
//  SESSION PROVIDERS
// ════════════════════════════════════════════════════════════

/// Bellenilen stol üçin aktiw sessiýalary yzarlaýar
final activeSessionsProvider =
    StreamProvider.family<List<PlayerSessionModel>, int>((ref, tableId) {
      final repo = ref.watch(sessionRepositoryProvider);
      return repo.watchActiveSessions(tableId);
    });

/// Bellenilen stol üçin tamamlanan sessiýalary yzarlaýar
final finishedSessionsProvider =
    StreamProvider.family<List<PlayerSessionModel>, int>((ref, tableId) {
      final repo = ref.watch(sessionRepositoryProvider);
      return repo.watchFinishedSessions(tableId);
    });

/// Stoluň taryh ýazgylary
final tableHistoryProvider = StreamProvider.family<List<HistoryLogModel>, int>((
  ref,
  tableId,
) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchTableHistory(tableId, limit: 20);
});

/// [playersPlayedInWindowProvider] üçin parametr
class PlayersWindowQuery {
  final int tableId;
  final DateTime start;
  final DateTime end;

  const PlayersWindowQuery({
    required this.tableId,
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) =>
      other is PlayersWindowQuery &&
      other.tableId == tableId &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(tableId, start, end);
}

/// Bellenilen stolda, şol wagt aralygynda bilelikde oýnan oýunçylaryň sessiýalary
final playersPlayedInWindowProvider =
    FutureProvider.family<List<PlayerSessionModel>, PlayersWindowQuery>((ref, query) {
      final repo = ref.watch(sessionRepositoryProvider);
      return repo.getPlayersPlayedInWindow(
        tableId: query.tableId,
        start: query.start,
        end: query.end,
      );
    });



/// Sessiýa işlemleri notifier-i
class SessionNotifier extends AsyncNotifier<void> {
  SessionRepository get _repo => ref.read(sessionRepositoryProvider);
  NotificationService get _notif => NotificationService();

  @override
  Future<void> build() async {}

  /// Bir oýunçy goş
  Future<void> addPlayer({
    required int tableId,
    required String playerName,
    int? reminderMinutes,
    int? customerId,
    double discountPercentage = 0.0,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final code = CodeGenerator.generateSessionCode();
      final session = PlayerSessionModel.create(
        tableId: tableId,
        playerName: playerName,
        sessionCode: code,
        reminderMinutes: reminderMinutes,
      )
        ..customerId = customerId
        ..discountPercentage = discountPercentage;
      final started = await _repo.startSession(session);

      if (reminderMinutes != null) {
        await _scheduleReminder(started);
      }
    });
  }

  /// Birnäçe oýunçy goş (Bulk Add)
  Future<void> addMultiplePlayers({
    required int tableId,
    required int count,
    required String baseName,
    int? reminderMinutes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      for (int i = 1; i <= count; i++) {
        final code = CodeGenerator.generateSessionCode();
        final session = PlayerSessionModel.create(
          tableId: tableId,
          playerName: '$baseName $i',
          sessionCode: code,
          reminderMinutes: reminderMinutes,
        );
        final started = await _repo.startSession(session);

        if (reminderMinutes != null) {
          await _scheduleReminder(started);
        }
      }
    });
  }

  /// Müşderini durdur we hasapla
  Future<StopResult> stopPlayer({
    required int sessionId,
    required int tableId,
    required String tableName,
    required double pricePerHour,
  }) async {
    // Önüm: sessiýa maglumatlaryny saklap, soňra ýap
    final isar = IsarService.isar;
    final session = await isar.playerSessionModels.get(sessionId);
    if (session == null) throw Exception('Sessiýa tapylmady');

    final activeSessions = await isar.playerSessionModels
        .filter()
        .tableIdEqualTo(tableId)
        .statusEqualTo(SessionStatus.active)
        .findAll();

    // Baha preview hasapla (UI üçin)
    final now = DateTime.now();
    final playerCount = activeSessions.length;
    double rawCost = session.accumulatedCost;
    final elapsed = now.difference(session.lastCheckpointTime);
    rawCost += PriceCalculator.segmentCostPerPlayer(
      pricePerHour: pricePerHour,
      durationSeconds: elapsed.inMilliseconds / 1000.0,
      playerCount: playerCount,
    );

    // Skidka hasapla
    final discount = session.discountPercentage;
    final discountAmount = rawCost * discount / 100.0;
    final finalCost = rawCost - discountAmount;

    // Repositoryde ýaz
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.stopSession(
        sessionId: sessionId,
        tableId: tableId,
        tableName: tableName,
        pricePerHour: pricePerHour,
        discountPercentage: discount,
        discountAmount: discountAmount,
      );
      // Bildirişi ýatyr
      await _notif.cancelReminder(sessionId);
    });

    return StopResult(
      sessionCode: session.sessionCode,
      playerName: session.playerName,
      startTime: session.startTime,
      endTime: now,
      rawPrice: rawCost,
      discountPercentage: discount,
      discountAmount: discountAmount,
      totalPrice: finalCost,
    );
  }

  /// Stoly doly ýap we umumy tölegi al
  Future<StopResult> stopTable({
    required int tableId,
    required String tableName,
    required double pricePerHour,
    required String payerName,
  }) async {
    state = const AsyncLoading();
    final log = await _repo.stopTable(
      tableId: tableId,
      tableName: tableName,
      pricePerHour: pricePerHour,
      payerName: payerName,
    );

    // Ähli aktiw bildirişleri ýatyr
    final isar = IsarService.isar;
    final sessions = await isar.playerSessionModels
        .filter()
        .tableIdEqualTo(tableId)
        .statusEqualTo(SessionStatus.active)
        .findAll();
    for (final s in sessions) {
      await _notif.cancelReminder(s.id);
    }

    state = const AsyncData(null);
    return StopResult(
      sessionCode: log.sessionCode,
      playerName: log.playerName,
      startTime: log.startTime,
      endTime: log.endTime,
      rawPrice: log.totalPrice + (log.discountAmount ?? 0),
      discountAmount: log.discountAmount ?? 0,
      totalPrice: log.totalPrice,
    );
  }

  /// Bildiriş baha ber we sazla
  Future<void> updateReminder(int sessionId, int? minutes) async {
    final isar = IsarService.isar;
    final session = await isar.playerSessionModels.get(sessionId);
    if (session == null) return;

    await isar.writeTxn(() async {
      session.reminderMinutes = minutes;
      await isar.playerSessionModels.put(session);
    });

    await _notif.cancelReminder(sessionId);
    if (minutes != null) {
      await _scheduleReminder(session);
    }
    ref.invalidate(activeSessionsProvider(session.tableId));
  }

  Future<void> _scheduleReminder(PlayerSessionModel session) async {
    if (session.reminderMinutes == null) return;

    final isar = IsarService.isar;
    final table = await isar.tableModels.get(session.tableId);
    final tableName = table?.name ?? 'Stol';

    final lang = ref.read(appLanguageProvider);
    final s = S(lang.locale ?? const Locale('tk'));

    final scheduledTime =
        session.startTime.add(Duration(minutes: session.reminderMinutes!));

    String timeText = '';
    final mins = session.reminderMinutes!;
    
    // Predetermined labels based on loc strings
    if (mins == 15) {
      timeText = s.min15;
    } else if (mins == 30) {
      timeText = s.min30;
    } else if (mins == 45) {
      timeText = s.min45;
    } else if (mins == 60) {
      timeText = s.h1;
    } else if (mins == 90) {
      timeText = s.h1_5;
    } else if (mins == 120) {
      timeText = s.h2;
    } else if (mins == 180) {
      timeText = s.h3;
    } else {
      timeText = '$mins min';
    }

    await _notif.scheduleReminder(
      sessionId: session.id,
      title: s.sessionReminderTitle(tableName),
      body: s.sessionReminderBody(session.playerName, timeText),
      scheduledTime: scheduledTime,
    );
  }
}

final sessionNotifierProvider = AsyncNotifierProvider<SessionNotifier, void>(
  SessionNotifier.new,
);

/// Sessiýany togtatmak netijesi (Checkout üçin)
class StopResult {
  final String sessionCode;
  final String playerName;
  final DateTime startTime;
  final DateTime endTime;
  final double rawPrice;
  final double discountPercentage;
  final double discountAmount;
  final double totalPrice;

  const StopResult({
    required this.sessionCode,
    required this.playerName,
    required this.startTime,
    required this.endTime,
    this.rawPrice = 0.0,
    this.discountPercentage = 0.0,
    this.discountAmount = 0.0,
    required this.totalPrice,
  });

  Duration get duration => endTime.difference(startTime);

  bool get hasDiscount => discountPercentage > 0;
}

// ════════════════════════════════════════════════════════════
//  REPORTS PROVIDERS
// ════════════════════════════════════════════════════════════

/// Hasabat filtri ýagdaýy
class ReportFilter {
  final DateTime from;
  final DateTime to;
  final int? tableId;

  const ReportFilter({required this.from, required this.to, this.tableId});

  ReportFilter copyWith({
    DateTime? from,
    DateTime? to,
    int? tableId,
    bool clearTable = false,
  }) {
    return ReportFilter(
      from: from ?? this.from,
      to: to ?? this.to,
      tableId: clearTable ? null : (tableId ?? this.tableId),
    );
  }
}

/// Hasabat filtri notifier-i
class ReportFilterNotifier extends Notifier<ReportFilter> {
  @override
  ReportFilter build() {
    final now = DateTime.now();
    return ReportFilter(
      from: AppFormatters.startOfDay(now),
      to: AppFormatters.endOfDay(now),
    );
  }

  void setFrom(DateTime dt) =>
      state = state.copyWith(from: AppFormatters.startOfDay(dt));
  void setTo(DateTime dt) =>
      state = state.copyWith(to: AppFormatters.endOfDay(dt));
  void setTable(int? tableId) =>
      state = state.copyWith(tableId: tableId, clearTable: tableId == null);
  void setToday() {
    final now = DateTime.now();
    state = ReportFilter(
      from: AppFormatters.startOfDay(now),
      to: AppFormatters.endOfDay(now),
      tableId: state.tableId,
    );
  }

  void setThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    state = ReportFilter(
      from: AppFormatters.startOfDay(startOfWeek),
      to: AppFormatters.endOfDay(now),
      tableId: state.tableId,
    );
  }

  void setThisMonth() {
    final now = DateTime.now();
    state = ReportFilter(
      from: DateTime(now.year, now.month, 1),
      to: AppFormatters.endOfDay(now),
      tableId: state.tableId,
    );
  }
}

final reportFilterProvider =
    NotifierProvider<ReportFilterNotifier, ReportFilter>(
      ReportFilterNotifier.new,
    );

/// Filterlenen taryh ýazgylary
final filteredHistoryProvider = FutureProvider<List<HistoryLogModel>>((
  ref,
) async {
  final filter = ref.watch(reportFilterProvider);
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getHistory(
    from: filter.from,
    to: filter.to,
    tableId: filter.tableId,
  );
});

/// Filterlenen jemi girdeji
final filteredRevenueProvider = FutureProvider<double>((ref) async {
  final filter = ref.watch(reportFilterProvider);
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getTotalRevenue(
    from: filter.from,
    to: filter.to,
    tableId: filter.tableId,
  );
});

// ════════════════════════════════════════════════════════════
//  THEME & LANGUAGE PROVIDERS (Persistent)
// ════════════════════════════════════════════════════════════

/// Tema ýagdaýy (system / light / dark)
class ThemeModeNotifier extends Notifier<ThemeMode> {
  final ThemeMode? initialMode;
  ThemeModeNotifier({this.initialMode});

  @override
  ThemeMode build() => initialMode ?? ThemeMode.system;

  void setTheme(ThemeMode mode) {
    state = mode;
    final isar = IsarService.isar;
    isar.writeTxn(() async {
      final settings =
          await isar.appSettingsModels.get(1) ?? AppSettingsModel();
      settings.themeModeIndex = mode.index;
      await isar.appSettingsModels.put(settings);
    });
  }

  void updateState(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Dil ýagdaýy (system / tk / ru / en)
class AppLanguageNotifier extends Notifier<AppLanguage> {
  final AppLanguage? initialLang;
  AppLanguageNotifier({this.initialLang});

  @override
  AppLanguage build() => initialLang ?? AppLanguage.system;

  void setLanguage(AppLanguage lang) {
    state = lang;
    final isar = IsarService.isar;
    isar.writeTxn(() async {
      final settings =
          await isar.appSettingsModels.get(1) ?? AppSettingsModel();
      settings.languageIndex = lang.index;
      await isar.appSettingsModels.put(settings);
    });
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLanguage>(
  AppLanguageNotifier.new,
);

// ════════════════════════════════════════════════════════════
//  DEVICE ACTIVATION PROVIDERS
// ════════════════════════════════════════════════════════════

final activationApiServiceProvider = Provider<ActivationApiService>(
  (ref) => ActivationApiService(),
);