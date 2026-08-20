import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TkMaterialLocalizations extends DefaultMaterialLocalizations {
  const TkMaterialLocalizations();

  @override
  String get okButtonLabel => 'OK';

  @override
  String get cancelButtonLabel => 'ÝATYR';

  @override
  String get saveButtonLabel => 'SAKLAMAK';

  @override
  String get closeButtonLabel => 'ÝAP';

  @override
  String get backButtonTooltip => 'Yza';

  @override
  String get moreButtonTooltip => 'Has köp';

  @override
  String get searchFieldLabel => 'Gözleg';

  @override
  String get datePickerHelpText => 'Sene saýla';

  // Sene saýlaw penjiresi üçin (DatePicker)
  @override
  String get dateInputLabel => 'Sene giriz';

  @override
  String get dateOutOfRangeLabel => 'Çäkden daşgary';

  @override
  String get invalidDateFormatLabel => 'Nädogry sene formady';

  @override
  String get invalidDateRangeLabel => 'Nädogry sene aralygy';

  // String get helpSidePanelTitle => 'Sene saýlawy kömegi';
}

class TkMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const TkMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tk';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(
      const TkMaterialLocalizations(),
    );
  }

  @override
  bool shouldReload(TkMaterialLocalizationsDelegate old) => false;
}

class TkCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const TkCupertinoLocalizations();

  @override
  DatePickerDateOrder get datePickerDateOrder => DatePickerDateOrder.dmy;

  @override
  DatePickerDateTimeOrder get datePickerDateTimeOrder =>
      DatePickerDateTimeOrder.date_time_dayPeriod;

  @override
  String get cutButtonLabel => 'Kes';

  @override
  String get copyButtonLabel => 'Göçür';

  @override
  String get pasteButtonLabel => 'Ýapmak';

  @override
  String get selectAllButtonLabel => 'Hemmesi';
}

class TkCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const TkCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tk';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(
      const TkCupertinoLocalizations(),
    );
  }

  @override
  bool shouldReload(TkCupertinoLocalizationsDelegate old) => false;
}

class TkWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const TkWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tk';

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return SynchronousFuture<WidgetsLocalizations>(
      const DefaultWidgetsLocalizations(),
    );
  }

  @override
  bool shouldReload(TkWidgetsLocalizationsDelegate old) => false;
}
