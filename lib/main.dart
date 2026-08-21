import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';


import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/tk_delegates.dart';
import 'core/services/notification_service.dart';
import 'data/local/isar_service.dart';
import 'data/models/app_settings_model.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/activation_gate_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  await IsarService.initialize();
  await NotificationService().initialize();

  ThemeMode initialTheme = ThemeMode.system;
  AppLanguage initialLang = AppLanguage.system;

  final settings = await IsarService.isar.appSettingsModels.get(1);
  if (settings != null) {
    initialTheme = ThemeMode.values[settings.themeModeIndex];
    initialLang = AppLanguage.values[settings.languageIndex];
  }

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith(
          () => ThemeModeNotifier(initialMode: initialTheme),
        ),
        appLanguageProvider.overrideWith(
          () => AppLanguageNotifier(initialLang: initialLang),
        ),
      ],
      child: const BilliardApp(),
    ),
  );
}

class BilliardApp extends ConsumerWidget {
  const BilliardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appLang = ref.watch(appLanguageProvider);

    final locale = appLang.locale;

    return MaterialApp(
      title: 'Sanly Timer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [Locale('tk'), Locale('ru'), Locale('en')],
      localizationsDelegates: const [
        S.delegate,
        TkMaterialLocalizationsDelegate(),
        TkCupertinoLocalizationsDelegate(),
        TkWidgetsLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ActivationGateScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
