import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'view_models/task_view_model.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/theme_view_model.dart';
import 'view_models/settings_view_model.dart';
import 'services/notification_service.dart';
import 'view_models/language_view_model.dart';
import 'views/screens/home/home_screen.dart';

const Color kPrimaryColor = Color(0xFF2c3e50);
const Color kAccentColor = Color(0xFF1abc9c);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeViewModel = ThemeViewModel();
  final languageViewModel = LanguageViewModel();
  final settingsViewModel = SettingsViewModel();

  await themeViewModel.loadThemeMode();
  await languageViewModel.loadLocale();
  await settingsViewModel.loadSettings();
  // Initialize notification service (timezone + platform init)
  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeViewModel),
        ChangeNotifierProvider.value(value: languageViewModel),
        ChangeNotifierProvider.value(value: settingsViewModel),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel()..signIn(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => TaskViewModel()..fetchTasks(),
          lazy: false,
        ),
      ],
      child: const DogoApp(),
    ),
  );
}

class DogoApp extends StatelessWidget {
  const DogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final languageViewModel = context.watch<LanguageViewModel>();

    return MaterialApp(
      title: 'DoGo AI Assistant',
      debugShowCheckedModeBanner: false,

      // --- langage management ---
      locale: languageViewModel.appLocale,
      supportedLocales: LanguageViewModel.supportedLocales,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) return supported;
        }
        return supportedLocales.first;
      },

      themeMode: themeViewModel.themeMode,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kAccentColor,
          primary: kPrimaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFf4f7f6),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kAccentColor,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kAccentColor,
          primary: kPrimaryColor,
          surface: const Color(0xFF1c2833),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color(0xFF1c2833),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kAccentColor,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),

      home: const HomeScreen(),
    );
  }
}
