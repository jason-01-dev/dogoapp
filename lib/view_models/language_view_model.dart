import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageViewModel extends ChangeNotifier {
  static const _localeKey = 'selectedAppLocale';

   
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'),
    Locale('en', 'US'),
  ];

   
  Locale _appLocale = const Locale('fr', 'FR');

  Locale get appLocale => _appLocale;

  // Simple in-app translations to avoid full gen-l10n flow for now.
  // Keys used in SettingsScreen and MapPicker.
  static const Map<String, Map<String, String>> _translations = {
    'fr': {
      'app_title': 'DoGo AI Assistant',
      'settings_title': 'Réglages IA de DoGo',
      'preferences_language': 'Préférences linguistiques',
      'app_language': 'Langue de l\'application',
      'theme_title': 'Thème de l\'application',
      'dark_mode': 'Mode sombre',
      'notifications': 'Notifications',
      'enable_notifications': 'Activer les notifications',
      'reminders': 'Rappels automatiques',
      'reminder_1h': '1 heure avant',
      'reminder_30m': '30 minutes avant',
      'reminder_10m': '10 minutes avant',
      'reminder_5m': '5 minutes avant',
      'default_address': 'Adresse par défaut',
      'choose_from_map': 'Choisir depuis la carte',
      'select': 'Sélectionner',
      'cancel': 'Annuler',
    },
    'en': {
      'app_title': 'DoGo AI Assistant',
      'settings_title': 'DoGo AI Settings',
      'preferences_language': 'Language preferences',
      'app_language': 'App language',
      'theme_title': 'App theme',
      'dark_mode': 'Dark mode',
      'notifications': 'Notifications',
      'enable_notifications': 'Enable notifications',
      'reminders': 'Automatic reminders',
      'reminder_1h': '1 hour before',
      'reminder_30m': '30 minutes before',
      'reminder_10m': '10 minutes before',
      'reminder_5m': '5 minutes before',
      'default_address': 'Default address',
      'choose_from_map': 'Choose from map',
      'select': 'Select',
      'cancel': 'Cancel',
    },
  };

  String t(String key) {
    final lang = _appLocale.languageCode;
    return _translations[lang]?[key] ?? _translations['fr']![key] ?? key;
  }

   
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangCode = prefs.getString(_localeKey);

    if (savedLangCode != null) {
      
      _appLocale = supportedLocales.firstWhere(
        (locale) => locale.languageCode == savedLangCode,
         
        orElse: () => const Locale('fr', 'FR'),
      );
    }
    
  }

   
  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
     
    await prefs.setString(_localeKey, locale.languageCode);
  }

   
  void changeLanguage(Locale newLocale) {
    if (_appLocale != newLocale) {
      _appLocale = newLocale;
      _saveLocale(newLocale);  
      notifyListeners();
      debugPrint(
          'Langue mise à jour et sauvegardée à : ${newLocale.languageCode}');
    }
  }
}
