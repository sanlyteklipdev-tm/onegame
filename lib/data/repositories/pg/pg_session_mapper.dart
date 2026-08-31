import '../../models/history_log_model.dart';
import '../../models/player_session_model.dart';

const sessionSelect = '''
SELECT id, table_id, player_name, session_code, start_time, end_time, status,
       accumulated_cost::float8    AS accumulated_cost,
       last_checkpoint_time,
       total_price::float8         AS total_price,
       customer_id,
       discount_percentage::float8 AS discount_percentage,
       reminder_minutes, device_name
FROM player_sessions
''';

const historySelect = '''
SELECT id, table_id, table_name, session_id, session_code, player_name,
       start_time, end_time,
       total_price::float8         AS total_price,
       discount_percentage::float8 AS discount_percentage,
       discount_amount::float8     AS discount_amount,
       created_at, device_name
FROM history_logs
''';

String sessionStatusToDb(SessionStatus s) =>
    s == SessionStatus.finished ? 'finished' : 'active';

SessionStatus sessionStatusFromDb(String s) =>
    s == 'finished' ? SessionStatus.finished : SessionStatus.active;

PlayerSessionModel mapSession(Map<String, dynamic> row) => PlayerSessionModel()
  ..id = row['id'] as int
  ..tableId = row['table_id'] as int
  ..playerName = row['player_name'] as String
  ..sessionCode = row['session_code'] as String
  ..startTime = (row['start_time'] as DateTime).toLocal()
  ..endTime = (row['end_time'] as DateTime?)?.toLocal()
  ..status = sessionStatusFromDb(row['status'] as String)
  ..accumulatedCost = (row['accumulated_cost'] as num).toDouble()
  ..lastCheckpointTime = (row['last_checkpoint_time'] as DateTime).toLocal()
  ..totalPrice = (row['total_price'] as num).toDouble()
  ..customerId = row['customer_id'] as int?
  ..discountPercentage = (row['discount_percentage'] as num).toDouble()
  ..reminderMinutes = row['reminder_minutes'] as int?
  ..deviceName = row['device_name'] as String?;

HistoryLogModel mapHistory(Map<String, dynamic> row) => HistoryLogModel()
  ..id = row['id'] as int
  ..tableId = row['table_id'] as int
  ..tableName = row['table_name'] as String
  ..sessionId = row['session_id'] as int
  ..sessionCode = row['session_code'] as String
  ..playerName = row['player_name'] as String
  ..startTime = (row['start_time'] as DateTime).toLocal()
  ..endTime = (row['end_time'] as DateTime).toLocal()
  ..totalPrice = (row['total_price'] as num).toDouble()
  ..discountPercentage = (row['discount_percentage'] as num?)?.toDouble()
  ..discountAmount = (row['discount_amount'] as num?)?.toDouble()
  ..createdAt = (row['created_at'] as DateTime).toLocal()
  ..deviceName = row['device_name'] as String?;
