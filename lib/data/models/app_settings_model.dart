import 'package:isar/isar.dart';

part 'app_settings_model.g.dart';

@collection
class AppSettingsModel {
  Id id = 1; // Diňe strow ýeke bolar

  bool isLicensed;
  int themeModeIndex;
  int languageIndex;

  AppSettingsModel({
    this.isLicensed = false,
    this.themeModeIndex = 0,
    this.languageIndex = 0,
  });
}
