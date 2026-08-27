// PostgreSQL gatlagynyň barlagy. Işletmek:
//   flutter test test/pg_smoke_test.dart
//
// Hakyky baza ýazýar, soňunda özünden soň arassalaýar.
// Baza işlemese test ýykylýar — bu barlagyň maksady.

import 'package:flutter_test/flutter_test.dart';

import 'package:onegame/data/models/customer_model.dart';
import 'package:onegame/data/models/employee_model.dart';
import 'package:onegame/data/models/player_session_model.dart';
import 'package:onegame/data/models/reservation_model.dart';
import 'package:onegame/data/models/table_model.dart';
import 'package:onegame/data/remote/postgres_service.dart';
import 'package:onegame/data/repositories/pg/pg_customer_repository.dart';
import 'package:onegame/data/repositories/pg/pg_employee_repository.dart';
import 'package:onegame/data/repositories/pg/pg_reservation_repository.dart';
import 'package:onegame/data/repositories/pg/pg_session_repository.dart';
import 'package:onegame/data/repositories/pg/pg_table_repository.dart';

void ok(String m) => print('  OK  $m');

void main() {
  test('PostgreSQL gatlagy doly işleýär', () async {
    print('== PostgreSQL smoke test ==');

    print('\n[1] birikme');
    final alive = await PostgresService.ping();
    expect(alive, isTrue, reason: 'baza bilen birikme ýok');
    ok('ping');

    final tables = PgTableRepository();
    final customers = PgCustomerRepository();
    final employees = PgEmployeeRepository();
    final sessions = PgSessionRepository();
    final reservations = PgReservationRepository();

    print('\n[2] stol');
    final table = await tables.createTable(
      TableModel.create(
        name: 'smoke-${DateTime.now().millisecondsSinceEpoch}',
        pricePerHour: 60,
      ),
    );
    ok('döredildi id=${table.id}, baha=${table.pricePerHour}');

    print('\n[3] müşderi we işgär');
    final customer = CustomerModel.create(
      name: 'smoke-mushderi-${table.id}',
      discountPercentage: 10,
    )..phone = '+99312345678';
    final customerId = await customers.save(customer);
    ok('müşderi id=$customerId, skidka=${customer.discountPercentage}');

    final employee = EmployeeModel.create(
      name: 'smoke-ishgar-${table.id}',
      category: EmployeeCategory.b,
    );
    final employeeId = await employees.save(employee);
    final savedEmp = await employees.getById(employeeId);
    ok('işgär id=$employeeId, kategoriýa=${savedEmp?.category.label}');

    print('\n[4] sessiýa: başlat -> sakla');
    final started = await sessions.startSession(
      PlayerSessionModel.create(
        tableId: table.id,
        playerName: 'smoke-oyunchy',
        sessionCode: 'SMK${table.id}',
      )..customerId = customerId,
    );
    ok('sessiýa id=${started.id}');

    final afterStart = await tables.getTableById(table.id);
    ok('stol ýagdaýy = ${afterStart?.status.name} (active bolmaly)');

    await Future<void>.delayed(const Duration(seconds: 2));

    await sessions.stopSession(
      sessionId: started.id,
      tableId: table.id,
      tableName: table.name,
      pricePerHour: table.pricePerHour,
    );
    final afterStop = await tables.getTableById(table.id);
    ok(
      'saklandy, stol ýagdaýy = ${afterStop?.status.name} (available bolmaly)',
    );

    final revenue = await sessions.getTotalRevenue(tableId: table.id);
    ok('girdeji = $revenue TMT');

    final history = await sessions.getHistory(
      from: DateTime.now().subtract(const Duration(hours: 1)),
      to: DateTime.now().add(const Duration(hours: 1)),
      tableId: table.id,
    );
    ok('taryh ýazgysy: ${history.length} sany');

    print('\n[5] bron we gabat gelme');
    final start = DateTime.now().add(const Duration(days: 1));
    final id1 = await reservations.save(
      ReservationModel.create(
        tableId: table.id,
        title: 'smoke-bron',
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
        customerId: customerId,
        employeeId: employeeId,
      ),
    );
    ok('bron döredildi id=$id1');

    final clash = await reservations.findOverlapping(
      tableId: table.id,
      start: start.add(const Duration(minutes: 30)),
      end: start.add(const Duration(hours: 2)),
    );
    ok('gabat gelme tapyldy: ${clash != null} (true bolmaly)');

    try {
      await reservations.save(
        ReservationModel.create(
          tableId: table.id,
          title: 'smoke-bron-2',
          startTime: start.add(const Duration(minutes: 30)),
          endTime: start.add(const Duration(hours: 2)),
        ),
      );
      fail('baza gabat gelýän brony kabul etdi!');
    } on TestFailure {
      rethrow;
    } catch (_) {
      ok('baza gabat gelýän brony ret etdi');
    }

    print('\n[6] arassalamak');
    await reservations.delete(id1);
    await tables.deleteTable(table.id); // sessiýalar cascade bilen gider
    await customers.delete(customerId);
    await employees.delete(employeeId);
    await PostgresService.query(
      'DELETE FROM history_logs WHERE table_id = @t',
      parameters: {'t': table.id},
    );
    ok('synag maglumatlary pozuldy');

    await PostgresService.close();
    print('\n== hemmesi gutardy ==');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
