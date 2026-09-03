import 'package:flutter/material.dart';

import '../../data/models/employee_model.dart';
import '../services/auth_service.dart';

/// Goldanýan diller
enum AppLanguage { system, tk, ru, en }

extension AppLanguageX on AppLanguage {
  String get displayName {
    switch (this) {
      case AppLanguage.system:
        return 'Default';
      case AppLanguage.tk:
        return 'Türkmen';
      case AppLanguage.ru:
        return 'Русский';
      case AppLanguage.en:
        return 'English';
    }
  }

  Locale? get locale {
    switch (this) {
      case AppLanguage.system:
        return null;
      case AppLanguage.tk:
        return const Locale('tk');
      case AppLanguage.ru:
        return const Locale('ru');
      case AppLanguage.en:
        return const Locale('en');
    }
  }
}

/// Terjimeler
class S {
  final Locale _locale;
  S(this._locale);

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S) ?? S(const Locale('tk'));
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  String get _lang => _locale.languageCode;

  // ── Navigation ─────────────────────────────────────
  String get tables => _t('Stol', 'Столы', 'Tables');
  String get reports => _t('Hasabat', 'Отчёты', 'Reports');
  String get settings => _t('Sazlama', 'Настройки', 'Settings');
  String get customers => _t('Müşderi', 'Клиенты', 'Customers');

  // ── Customers Screen ───────────────────────────────
  String get addCustomer =>
      _t('Müşderi goş', 'Добавить клиента', 'Add Customer');
  String get editCustomer =>
      _t('Müşderi üýtget', 'Изменить клиента', 'Edit Customer');
  String get deleteCustomer =>
      _t('Müşderi poz', 'Удалить клиента', 'Delete Customer');
  String deleteCustomerConfirm(String name) => _t(
    '"$name" pozulyp bilinmez. Dowam etmelimi?',
    'Клиент "$name" будет удалён. Продолжить?',
    'Customer "$name" will be deleted. Continue?',
  );
  String get noCustomers => _t('Müşderi ýok', 'Клиентов нет', 'No Customers');
  String get noCustomersHint => _t(
    'Müşderi goşmak üçin + düwmä basyň',
    'Нажмите + чтобы добавить клиента',
    'Tap + to add a customer',
  );
  String get customerName => _t('Müşderi ady', 'Имя клиента', 'Customer Name');
  String get customerNameHint =>
      _t('Meselem: Serdar', 'Например: Иван', 'e.g. John');
  String get discountPercent => _t('Skidka (%)', 'Скидка (%)', 'Discount (%)');
  String get discount => _t('Skidka', 'Скидка', 'Discount');
  String get noDiscount => _t('Skidka ýok', 'Без скидки', 'No discount');
  String get discountAmount =>
      _t('Skidka mukdary', 'Сумма скидки', 'Discount amount');
  String get selectCustomer =>
      _t('Müşderi saýla', 'Выбрать клиента', 'Select Customer');
  String get noCustomer => _t('Müşderisiz', 'Без клиента', 'No customer');
  String get addMore => _t('Ýene goş', 'Добавить ещё', 'Add more');
  String get search => _t('Gözle...', 'Поиск...', 'Search...');
  String get noResults =>
      _t('Netije tapylmady', 'Результатов нет', 'No results found');
  String get tryDifferentSearch => _t(
    'Başga söz bilen gözläň',
    'Попробуйте другой запрос',
    'Try a different search query',
  );

  // ── Işgärler (Staff) ───────────────────────────────
  String get employees => _t('Işgär', 'Персонал', 'Staff');
  String get addEmployee =>
      _t('Işgär goş', 'Добавить сотрудника', 'Add Staff');
  String get editEmployee =>
      _t('Işgäri üýtget', 'Изменить сотрудника', 'Edit Staff');
  String get deleteEmployee =>
      _t('Işgäri poz', 'Удалить сотрудника', 'Delete Staff');
  String deleteEmployeeConfirm(String name) => _t(
    '"$name" pozulyp bilinmez. Dowam etmelimi?',
    'Сотрудник "$name" будет удалён. Продолжить?',
    'Staff member "$name" will be deleted. Continue?',
  );
  String get noEmployees => _t('Işgär ýok', 'Сотрудников нет', 'No Staff');
  String get noEmployeesHint => _t(
    'Işgär goşmak üçin + düwmä basyň',
    'Нажмите + чтобы добавить сотрудника',
    'Tap + to add a staff member',
  );
  String get employeeName =>
      _t('Işgäriň ady', 'Имя сотрудника', 'Staff Name');
  String get employeePosition => _t('Wezipe', 'Должность', 'Position');
  String get customerCategory =>
      _t('Kategoriýa', 'Категория', 'Category');

  /// Işgäriň wezipesiniň ady
  String positionLabel(EmployeePosition p) => switch (p) {
    EmployeePosition.manager => _t('Menejer', 'Менеджер', 'Manager'),
    EmployeePosition.cashier => _t('Kassir', 'Кассир', 'Cashier'),
    EmployeePosition.operator => _t('Operator', 'Оператор', 'Operator'),
    EmployeePosition.director => _t('Direktor', 'Директор', 'Director'),
  };
  String get noEmployee => _t('Işgärsiz', 'Без сотрудника', 'No staff');

  // ── Işgäriň ekrany ─────────────────────────────────────
  String get myBookings => _t('Meniň bronlarym', 'Мои брони', 'My bookings');
  String get markDone =>
      _t('Ýerine ýetirildi', 'Выполнено', 'Mark done');
  String get statusPending => _t('Garaşylýar', 'Ожидает', 'Pending');
  String get statusStarted => _t('Başladyldy', 'Начата', 'Started');
  String get statusDone => _t('Ýerine ýetirildi', 'Выполнено', 'Done');
  String get noMyBookings =>
      _t('Bron ýok', 'Броней нет', 'No bookings');
  String get noMyBookingsHint => _t(
    'Size bron bellenende şu ýerde görüner',
    'Когда на вас назначат бронь, она появится здесь',
    'Bookings assigned to you will appear here',
  );
  /// Işgäre täze bron bellenende — şol pursat
  String get newBookingTitle =>
      _t('Täze bron', 'Новая бронь', 'New booking');
  String newBookingBody(String title, String table, String time) => _t(
    '$title · $table · $time',
    '$title · $table · $time',
    '$title · $table · $time',
  );

  /// Başlamazyndan 30 minut öň
  String get bookingSoonTitle =>
      _t('30 minutdan bron', 'Бронь через 30 минут', 'Booking in 30 minutes');

  /// Başlaýan pursadynda
  String get bookingNowTitle =>
      _t('Bronuň wagty geldi', 'Время брони', 'Booking time');

  String get notLinkedToEmployee => _t(
    'Bu hasap hiç işgäre baglanmadyk. Administratora ýüz tutuň',
    'Эта учётная запись не привязана к сотруднику. Обратитесь к администратору',
    'This account is not linked to a staff member. Contact the administrator',
  );

  // ── Giriş (Login) ──────────────────────────────────────
  String get account => _t('Hasap', 'Учётная запись', 'Account');
  String get signInTitle => _t('Ulgama giriş', 'Вход в систему', 'Sign in');
  String get signInSubtitle => _t(
    'Öz adyňyz we parolyňyz bilen giriň',
    'Введите свой логин и пароль',
    'Enter your username and password',
  );
  String get username => _t('Ulanyjy ady', 'Логин', 'Username');
  String get password => _t('Parol', 'Пароль', 'Password');
  String get signIn => _t('Gir', 'Войти', 'Sign in');
  String get signOut => _t('Çyk', 'Выйти', 'Sign out');
  String get signOutConfirm => _t(
    'Ulgamdan çykmalymy?',
    'Выйти из системы?',
    'Sign out of the app?',
  );
  String get enterUsername =>
      _t('Ulanyjy adyny ýazyň', 'Введите логин', 'Enter a username');
  String get enterPassword =>
      _t('Paroly ýazyň', 'Введите пароль', 'Enter a password');
  String get errWrongCredentials => _t(
    'Ulanyjy ady ýa parol ýalňyş',
    'Неверный логин или пароль',
    'Wrong username or password',
  );
  String get errDbUnreachable => _t(
    'Baza birigip bolmady. Wi-Fi we kompýuter açykmy?',
    'Нет связи с базой. Проверьте Wi-Fi и компьютер',
    'Cannot reach the database. Check Wi-Fi and the computer',
  );
  String get errNoRole => _t(
    'Bu hasaba rol berilmedik. Administratora ýüz tutuň',
    'Этой учётной записи не назначена роль. Обратитесь к администратору',
    'This account has no role assigned. Contact the administrator',
  );
  String get signedInAs =>
      _t('Giren', 'Вы вошли как', 'Signed in as');

  /// Rolyň ady
  String roleLabel(AppRole r) => switch (r) {
    AppRole.worker => _t('Ulanyjy', 'Пользователь', 'User'),
    AppRole.manager => _t('Menejer', 'Менеджер', 'Manager'),
    AppRole.admin => _t('Administrator', 'Администратор', 'Administrator'),
  };

  String get employeeType => _t('Görnüş', 'Тип', 'Type');

  /// Işgäriň görnüşiniň ady
  String typeLabel(EmployeeType t) => switch (t) {
    EmployeeType.type1 => _t('1-nji görnüş', 'Тип 1', 'Type 1'),
    EmployeeType.type2 => _t('2-nji görnüş', 'Тип 2', 'Type 2'),
  };

  /// Bronda saýlar ýaly 2-nji görnüşdäki işgär ýok
  String get noType2Employees => _t(
    '2-nji görnüşdäki işgär ýok',
    'Нет сотрудников типа 2',
    'No Type 2 staff',
  );

  // ── Maglumat bazasy ────────────────────────────────
  String get database => _t('Maglumat bazasy', 'База данных', 'Database');
  String get dbCurrentSource =>
      _t('Häzirki çeşme', 'Текущий источник', 'Current source');
  String get dbLocalIsar =>
      _t('Isar (enjamyň özünde)', 'Isar (на устройстве)', 'Isar (on device)');
  String get dbPostgres => 'PostgreSQL';
  String get dbConnected => _t('Birikdirildi', 'Подключено', 'Connected');
  String get dbNotConnected =>
      _t('Birikme ýok', 'Нет подключения', 'Not connected');
  String get dbCheckConnection =>
      _t('Birikmäni barla', 'Проверить подключение', 'Check connection');

  // ── Enjamlar ───────────────────────────────────────
  String get device => _t('Enjam', 'Устройство', 'Device');
  String get thisDeviceName =>
      _t('Bu enjamyň ady', 'Имя этого устройства', 'This device name');
  String get deviceNameHint =>
      _t('Meselem: Kassa', 'Например: Касса', 'e.g. Front desk');
  String get deviceNameSaved =>
      _t('Enjamyň ady ýatda saklandy', 'Имя устройства сохранено', 'Device name saved');
  String get deviceNameExplain => _t(
    'Şu enjamdan goşulan ýazgylarda bu at görkeziler.',
    'Это имя будет показано у записей, добавленных с этого устройства.',
    'This name is shown on records added from this device.',
  );
  String get allDevices => _t('Ähli enjamlar', 'Все устройства', 'All devices');
  String get unknownDevice => _t('Näbelli', 'Неизвестно', 'Unknown');

  // ── Umumy meýdanlar ────────────────────────────────
  String get phone => _t('Telefon', 'Телефон', 'Phone');
  String get phoneOptional =>
      _t('Hökman däl', 'Необязательно', 'Optional');

  // ── Hyzmatlar (Services) ───────────────────────────
  String get services => _t('Hyzmat', 'Услуги', 'Services');
  String get addService => _t('Hyzmat goş', 'Добавить услугу', 'Add Service');
  String get editService =>
      _t('Hyzmaty üýtget', 'Изменить услугу', 'Edit Service');
  String get deleteService =>
      _t('Hyzmaty poz', 'Удалить услугу', 'Delete Service');
  String deleteServiceConfirm(String name) => _t(
    '"$name" pozulyp bilinmez. Dowam etmelimi?',
    'Услуга "$name" будет удалена. Продолжить?',
    'Service "$name" will be deleted. Continue?',
  );
  String get noServices => _t('Hyzmat ýok', 'Услуг нет', 'No Services');
  String get noServicesHint => _t(
    'Hyzmat goşmak üçin + düwmä basyň',
    'Нажмите + чтобы добавить услугу',
    'Tap + to add a service',
  );
  String get serviceName => _t('Hyzmatyň ady', 'Название услуги', 'Service Name');
  String get serviceNameHint =>
      _t('Meselem: Klassiki massaž', 'Например: Классический массаж', 'e.g. Classic massage');
  String get servicePrice => _t('Baha (TMT)', 'Цена (TMT)', 'Price (TMT)');
  String get selectService =>
      _t('Hyzmat saýlaň', 'Выберите услугу', 'Select service');
  String get selectServiceFirst => _t(
    'Hyzmat saýlaň',
    'Выберите услугу',
    'Select a service',
  );

  // ── Tables Screen ─────────────────────────────────
  String get appTitle => 'Sanly Timer';
  String activeTablesCount(int active, int total) => _t(
    '$active aktiw / $total stol',
    '$active акт. / $total стол',
    '$active active / $total tables',
  );
  String get addTable => _t('Stol goş', 'Добавить стол', 'Add Table');
  String get noTables => _t('Stol ýok', 'Нет столов', 'No Tables');
  String get noTablesHint => _t(
    'Oýunçylary goşmak üçin ilki stol goşuň',
    'Добавьте первый стол для начала',
    'Add your first table to get started',
  );
  String get errorPrefix => _t('Ýalňyşlyk', 'Ошибка', 'Error');
  String get searchTableHint =>
      _t('Stol adyny gözle...', 'Поиск стола...', 'Search table...');
  String get noSearchResult =>
      _t('Şeýle atly stol tapylmady', 'Стол не найден', 'No table found');
  String get active => _t('Aktiw', 'Активен', 'Active');
  String get available => _t('Boş', 'Свободен', 'Available');
  String personCount(int n) => _t('$n adam', '$n чел.', '$n players');
  String get perHour => _t('/sagat', '/час', '/hour');
  String get perHourShort => _t('TMT/sag', 'TMT/час', 'TMT/hr');

  // ── Table Detail ───────────────────────────────────
  String get tableTotalBill =>
      _t('Stoluň umumy hasaby', 'Общий счёт стола', 'Table Total');
  String get time => _t('Wagt', 'Время', 'Time');
  String get activePlayers =>
      _t('Aktiw oýunçylar', 'Активные игроки', 'Active Players');
  String get addPlayer => _t('Oýunçy goşmak', 'Добавить игрока', 'Add Player');
  String get addPlayersHint =>
      _t('Oýunçy goşmak', 'Добавьте игрока', 'Add players');
  String get recentActions =>
      _t('Soňky hereketler', 'Последние действия', 'Recent Actions');
  String get noFinishedSessions => _t(
    'Entäk tamamlanan sessiýa ýok',
    'Нет завершённых сессий',
    'No completed sessions yet',
  );
  String get stop => _t('Sakla', 'Стоп', 'Stop');

  // ── Add Table Sheet ────────────────────────────────
  String get addNewTable => _t('Täze stol goş', 'Новый стол', 'Add New Table');
  String get editTable => _t('Stoly üýtget', 'Изменить стол', 'Edit Table');
  String get tableName => _t('Stol ady', 'Название стола', 'Table Name');
  String get tableNameHint =>
      _t('Meselem: Stol 1', 'Например: Стол 1', 'e.g. Table 1');
  String get pricePerHour =>
      _t('Sagatlyk baha (TMT)', 'Цена за час (TMT)', 'Price per hour (TMT)');
  String get enterName => _t('Adyny ýazyň', 'Введите название', 'Enter name');
  String get enterPrice => _t('Bahany ýazyň', 'Введите цену', 'Enter price');
  String get invalidNumber =>
      _t('San ýazyň', 'Введите число', 'Enter valid number');
  String get add => _t('Goşmak', 'Добавить', 'Add');
  String get save => _t('Ýatda sakla', 'Сохранить', 'Save');

  // ── Add Session Sheet ──────────────────────────────
  String get addPlayerTitle => _t('Oýun goş', 'Добавить игрока', 'Add Player');
  String get singleAdd => _t('Ýeke-ýekeden', 'По одному', 'Single');
  String get bulkAdd => _t('Köp adam (Bulk)', 'Несколько (Bulk)', 'Bulk Add');
  String get playerName => _t('Müşderiniň ady', 'Имя клиента', 'Player Name');
  String get playerNameHint =>
      _t('Meselem: Serdar', 'Например: Иван', 'e.g. John');
  String get howManyPlayers =>
      _t('Näçe adam?', 'Сколько человек?', 'How many players?');
  String get defaultPlayerName => _t('Adam', 'Игрок', 'Player');
  String get bulkAddHint => _t(
    'Oýunçylar awtomatiki "$defaultPlayerName 1, $defaultPlayerName 2..." diýip goşular.',
    'Игроки добавятся автоматически как "$defaultPlayerName 1, $defaultPlayerName 2..."',
    'Players will be auto-named "$defaultPlayerName 1, $defaultPlayerName 2..."',
  );
  String get confirmAndStart =>
      _t('Tassykla we başlat', 'Подтвердить', 'Confirm & Start');

  // ── Table Checkout (Umumy) ─────────────────────────
  String get closeTotalTable =>
      _t('Umumy töleg', 'Общий счёт', 'Pay Total Bill');
  String get closeTotalTablePrompt => _t(
    'Stol boýunça ähli aktiw oýunçylaryň tölegini bir adam töleýärmi?',
    'Один человек оплачивает общий счёт стола за всех активных игроков?',
    'Will one person pay the total bill for all active players at the table?',
  );
  String get generalCustomerName =>
      _t('Umumy Müşderi', 'Общий клиент', 'General Customer');
  String get payerNameHint => _t(
    'Töleýji (görkezilmese: $generalCustomerName)',
    'Имя плательщика (По ум.: $generalCustomerName)',
    'Payer Name (Default: $generalCustomerName)',
  );
  String get collectivePayment =>
      _t('Doly töleg', 'Коллективный платёж', 'Collective Payment');
  String get tmt => 'TMT';

  // ── Checkout ───────────────────────────────────────
  String get checkout => _t('Hasaplaşyk', 'Расчёт', 'Checkout');
  String get players => _t('Oýunçylar', 'Игроки', 'Players');
  String get confirmed => _t('Tassyklandy', 'Подтверждено', 'Confirmed');
  String get customer => _t('Müşderi', 'Клиент', 'Customer');
  String get code => _t('Kod', 'Код', 'Code');
  String get table => _t('Stol', 'Стол', 'Table');
  String get started => _t('Başlan', 'Начало', 'Started');
  String get duration => _t('Dowamlylygy', 'Длительность', 'Duration');
  String get playersAtTable =>
      _t('Stoldaky adam', 'Игроков за столом', 'Players at table');
  String playersSplit(int n) =>
      _t('$n adam (bölüşdi)', '$n чел. (разделено)', '$n players (split)');
  String get totalPayment =>
      _t('Jemi töleg', 'Итого к оплате', 'Total Payment');
  String get confirm => _t('Tassykla', 'Подтвердить', 'Confirm');
  String get calculating =>
      _t('Hasaplanýar...', 'Считаем...', 'Calculating...');
  String get back => _t('Yza', 'Назад', 'Back');
  String get showReceipt => _t('Çek görkez', 'Показать чек', 'Show Receipt');
  String get close => _t('Ýakyn', 'Закрыть', 'Close');

  // ── Receipt ────────────────────────────────────────
  String get receiptTitle => '★ SANLY TIMER ★';
  String get customerLabel => _t('Müşderi:', 'Клиент:', 'Customer:');
  String get codeLabel => _t('Kod:', 'Код:', 'Code:');
  String get tableLabel => _t('Stol:', 'Стол:', 'Table:');
  String get startedLabel => _t('Başlan:', 'Начало:', 'Started:');
  String get finishedLabel => _t('Tamamlandy:', 'Завершено:', 'Finished:');
  String get durationLabel => _t('Dowamlylygy:', 'Длитель.:', 'Duration:');
  String get priceLabel => _t('Baha:', 'Цена:', 'Price:');
  String get totalPaymentLabel => _t('JEMI TÖLEG:', 'ИТОГО:', 'TOTAL:');
  String get thankYou => _t('Sag boluň!', 'Спасибо!', 'Thank you!');

  // ── Reports ────────────────────────────────────────
  String get today => _t('Şu gün', 'Сегодня', 'Today');
  String get thisWeek => _t('Bu hepde', 'Эта неделя', 'This Week');
  String get thisMonth => _t('Bu aý', 'Этот месяц', 'This Month');
  String get startDate => _t('Başlangyjy', 'Начало', 'Start');
  String get endDate => _t('Ahyry', 'Конец', 'End');
  String get allTables => _t('Ähli stollar', 'Все столы', 'All Tables');
  String get totalRevenue => _t('Jemi girdeji', 'Общий доход', 'Total Revenue');
  String get sessionsCount => _t('Sessiýa sany', 'Кол-во сессий', 'Sessions');
  String get noHistory => _t(
    'Bu aralykda ýazgy ýok',
    'Нет записей за период',
    'No records for this period',
  );
  String get history => _t('Taryh', 'История', 'History');

  // ── Settings ───────────────────────────────────────
  String get manageTable =>
      _t('Stol dolandyryş', 'Управление столами', 'Manage Tables');
  String get emptyList => _t('Sanaw boş', 'Список пуст', 'List is empty');
  String get aboutApp => _t('Programma barada', 'О программе', 'About App');
  String get version => _t('Wersiýa', 'Версия', 'Version');
  String get appName => 'Sanly Timer';
  String get dataStorage => _t('Maglumatlar', 'Данные', 'Data');
  String get localOnly => _t(
    'Diňe enjamda saklanýar',
    'Хранятся только на устройстве',
    'Stored locally only',
  );
  String get deleteTable => _t('Stoly poz', 'Удалить стол', 'Delete Table');
  String tableDeleteConfirm(String name) => _t(
    '$name bilen baglanyşykly ähli taryh ýazgylary saklanar, ýöne stol pozular. Dowam etmelimi?',
    'Все записи, связанные с $name, будут сохранены, но стол будет удалён. Продолжить?',
    'All records related to $name will be preserved, but the table will be deleted. Continue?',
  );
  String tableActiveError(String name) => _t(
    '$name häzir aktiw. Ilki ähli oýunçylary tamamladyň.',
    '$name сейчас активен. Сначала завершите все сессии.',
    '$name is currently active. Finish all sessions first.',
  );
  String get cancel => _t('Ýatyr', 'Отмена', 'Cancel');
  String get delete => _t('Poz', 'Удалить', 'Delete');

  // ── Theme & Language ───────────────────────────────
  String get appearance => _t('Tema', 'Оформление', 'Appearance');
  String get theme => _t('Tema', 'Тема', 'Theme');
  String get themeSystem => _t('Sistema', 'Системная', 'System');
  String get themeLight => _t('Ýagty', 'Светлая', 'Light');
  String get themeDark => _t('Garaňky', 'Тёмная', 'Dark');
  String get language => _t('Dil', 'Язык', 'Language');

  // ── Device Activation ──────────────────────────────
  String get activationCheckTitle =>
      _t('Aktiwlik barlagy', 'Проверка активации', 'Activation Check');
  String get checkActivation => _t('BARLAMAK', 'ПРОВЕРИТЬ', 'CHECK');
  String get retry =>
      _t('GAÝTADAN SYNANYŞMAK', 'ПОВТОРИТЬ', 'RETRY');
  String get waitingActivationTitle => _t(
    'Tassyklama garaşylýar',
    'Ожидание подтверждения',
    'Awaiting Confirmation',
  );
  String get waitingActivationBody => _t(
    'Dolandyryjy enjamyňyzy tassyklanda, aşakdaky düwmä basyp barlaň.',
    'Когда администратор подтвердит ваше устройство, нажмите кнопку ниже, чтобы проверить.',
    'Once the admin confirms your device, tap the button below to check.',
  );
  String get deviceNotConfirmedYet => _t(
    'Enjam heniz tassyklanmady. Garaşyň.',
    'Устройство ещё не подтверждено. Подождите.',
    'Device not confirmed yet. Please wait.',
  );
  String get deviceActiveMessage => _t(
    'Enjam aktiw we tassyklandy.',
    'Устройство активно и подтверждено.',
    'Device is active and confirmed.',
  );
  String get noInternetConnection => _t(
    'Internet ýok. Baglanyşygy barlaň.',
    'Нет подключения к интернету.',
    'No internet connection.',
  );
  String get noInternetFirstCheck => _t(
    'Ilkinji barlag üçin internet gerek.',
    'Для первой проверки нужен интернет.',
    'Internet connection is required for the first check.',
  );

  // ── Bron (Reservations) ────────────────────────────
  String get reservations => _t('Bron', 'Бронь', 'Booking');
  String get newReservation => _t('Täze bron', 'Новая бронь', 'New Booking');
  String get editReservation =>
      _t('Brony üýtget', 'Изменить бронь', 'Edit Booking');
  String get reservationName => _t('Ady', 'Название', 'Title');
  String get reservationNameHint =>
      _t('Meselem: Serdar', 'Например: Иван', 'e.g. John');
  String get reservationStartsAt => _t('Başlaýar', 'Начало', 'Starts');
  String get reservationEndsAt => _t('Tamamlanýar', 'Конец', 'Ends');
  String get reservationReminderInfo => _t(
    '30 minut öňünden we başlanda duýduryş geler',
    'Уведомление придёт за 30 минут и в момент начала',
    'Notified 30 minutes before and at the start',
  );
  String addBookingOn(String date) =>
      _t('$date üçin bron goş', 'Доб. бронь $date', 'Add booking on $date');
  String get noReservationsForDay => _t(
    'Bu gün üçin bron ýok',
    'На этот день броней нет',
    'No bookings for this day',
  );
  String get startTableNow => _t('BAŞLAT', 'ЗАПУСТИТЬ', 'START');
  String reservationOverlapError(String tableName) => _t(
    '$tableName şol wagt aralygynda eýýäm bronlanan.',
    '$tableName уже забронирован на это время.',
    '$tableName is already booked for that time.',
  );
  String get reservationEndBeforeStart => _t(
    'Tamamlanýan wagt başlangyçdan soň bolmaly.',
    'Время конца должно быть позже начала.',
    'End time must be after the start time.',
  );
  String get reservationInPast => _t(
    'Geçen wagt üçin bron edip bolmaýar.',
    'Нельзя забронировать на прошедшее время.',
    'You cannot book a time in the past.',
  );
  String get deleteReservation =>
      _t('Brony poz', 'Удалить бронь', 'Delete Booking');
  String reservationDeleteConfirm(String name) => _t(
    '"$name" brony pozulsynmy?',
    'Удалить бронь "$name"?',
    'Delete booking "$name"?',
  );
  String get reservationStartedLabel =>
      _t('Başladyldy', 'Запущено', 'Started');
  String get reservationPendingLabel =>
      _t('Garaşylýar', 'Ожидает', 'Pending');
  String get selectTableFirst => _t(
    'Ilki stol saýlaň',
    'Сначала выберите стол',
    'Select a table first',
  );
  String get selectTable =>
      _t('Stol saýlaň', 'Выберите стол', 'Select table');
  String get reservationTableStarted => _t(
    'Stol başladyldy',
    'Стол запущен',
    'Table started',
  );
  String get reservationReminderSoonTitle =>
      _t('Bron ýatlatmasy', 'Напоминание о брони', 'Booking reminder');
  String reservationReminderSoonBody(String name, String table, String time) =>
      _t(
        '$name — $table, $time başlaýar (30 minut galdy)',
        '$name — $table, начало в $time (осталось 30 минут)',
        '$name — $table starts at $time (30 minutes left)',
      );
  String get reservationReminderNowTitle =>
      _t('Bron wagty geldi', 'Время брони', 'Booking time');
  String reservationReminderNowBody(String name, String table) => _t(
    '$name — $table indi başlamaly',
    '$name — $table, пора начинать',
    '$name — $table is due to start now',
  );

  /// Aýyň gysga ady: 'AWG.' / 'АВГ.' / 'AUG'
  String monthShort(int month) {
    const tk = [
      'ÝAN.', 'FEW.', 'MAR.', 'APR.', 'MAÝ', 'IÝN.',
      'IÝL.', 'AWG.', 'SEN.', 'OKT.', 'NOÝ.', 'DEK.',
    ];
    const ru = [
      'ЯНВ.', 'ФЕВР.', 'МАРТ', 'АПР.', 'МАЙ', 'ИЮНЬ',
      'ИЮЛЬ', 'АВГ.', 'СЕНТ.', 'ОКТ.', 'НОЯБ.', 'ДЕК.',
    ];
    const en = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    final i = (month - 1).clamp(0, 11);
    return _t(tk[i], ru[i], en[i]);
  }

  /// Hepdäniň gününiň doly ady: 'çarşenbe' / 'среда' / 'Wednesday'
  String weekdayFull(int weekday) {
    const tk = [
      'duşenbe', 'sişenbe', 'çarşenbe', 'penşenbe',
      'anna', 'şenbe', 'ýekşenbe',
    ];
    const ru = [
      'понедельник', 'вторник', 'среда', 'четверг',
      'пятница', 'суббота', 'воскресенье',
    ];
    const en = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final i = (weekday - 1).clamp(0, 6);
    return _t(tk[i], ru[i], en[i]);
  }

  /// Hepdäniň gününiň gysga ady: 'çar' / 'ср' / 'Wed'
  String weekdayShort(int weekday) {
    const tk = ['duş', 'siş', 'çar', 'pen', 'ann', 'şen', 'ýek'];
    const ru = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final i = (weekday - 1).clamp(0, 6);
    return _t(tk[i], ru[i], en[i]);
  }

  /// 'çar, 26 awg.' / 'ср, 26 авг.' / 'Wed, Aug 26'
  String shortDateLabel(DateTime dt) {
    final wd = weekdayShort(dt.weekday);
    final mo = monthShort(dt.month);
    return _lang == 'en' ? '$wd, $mo ${dt.day}' : '$wd, ${dt.day} ${mo.toLowerCase()}';
  }

  // ── Session Tile ───────────────────────────────────
  // (reuse stop, already defined)

  String durationReadable(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0 && m > 0) {
      return '$h ${_t('s', 'ч', 'h')} $m ${_t('m', 'м', 'm')}';
    }
    if (h > 0) return '$h ${_t('sagat', 'час', 'hour')}';
    if (m > 0) return '$m ${_t('minut', 'мин', 'min')}';
    return '$s ${_t('sekunt', 'сек', 'sec')}';
  }

  // ── Reminders ──────────────────────────────────────
  String get reminder => _t('Bildiriş', 'Уведомление', 'Reminder');
  String get noReminder => _t('Bildiriş ýok', 'Без уведомления', 'No Reminder');
  String get reminderSet =>
      _t('Bildiriş bellenildi', 'Уведомление установлено', 'Reminder set');
  String get min15 => _t('15 minut', '15 минут', '15 minutes');
  String get min30 => _t('30 minut', '30 минут', '30 minutes');
  String get min45 => _t('45 minut', '45 минут', '45 minutes');
  String get h1 => _t('1 sagat', '1 час', '1 hour');
  String get h1_5 => _t('1.5 sagat', '1.5 часа', '1.5 hours');
  String get h2 => _t('2 sagat', '2 часа', '2 hours');
  String get h3 => _t('3 sagat', '3 часа', '3 hours');

  String sessionReminderTitle(String tableName) =>
      _t('$tableName wagty', 'Время $tableName', '$tableName Time');
  String sessionReminderBody(String playerName, String time) => _t(
    '$playerName - $time boldy!',
    '$playerName - $time прошло!',
    '$playerName - $time reached!',
  );

  /// Kömekçi terjime funksiýasy
  String _t(String tk, String ru, String en) {
    switch (_lang) {
      case 'ru':
        return ru;
      case 'en':
        return en;
      default:
        return tk;
    }
  }
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['tk', 'ru', 'en'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) async => S(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<S> old) => false;
}
