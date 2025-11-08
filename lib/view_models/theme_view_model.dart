import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const _themeKey = 'selectedThemeMode';

  // Défini par défaut sur Système.
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Utilitaire pour vérifier si le mode DARK est explicitement sélectionné.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // --- LOGIQUE DE CHARGEMENT AMÉLIORÉE (Utilisation de firstWhere) ---
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeString = prefs.getString(_themeKey);

    // Convertit la chaîne sauvegardée ('light', 'dark', 'system') en ThemeMode.
    // Utilise 'system' par défaut si rien n'est trouvé.
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString().split('.').last == (savedThemeString ?? 'system'),
      orElse: () => ThemeMode.system,
    );
  }

  // --- LOGIQUE DE SAUVEGARDE (Gère 'system' via split('.').last) ---
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    // Extrait la chaîne simple ('light', 'dark' ou 'system').
    final modeString = mode.toString().split('.').last;

    await prefs.setString(_themeKey, modeString);
  }

  // ✅ Méthode UNIQUE pour définir n'importe quel ThemeMode (Light, Dark, System)
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveThemeMode(_themeMode); // Sauvegarde asynchrone
      notifyListeners();
      debugPrint('Thème mis à jour et sauvegardé : $mode');
    }
  }
}
