import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import pour la persistance
import '../models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  // Clés de persistance pour SharedPreferences
  static const _focusTimeKey = 'dailyFocusTimeMinutes';
  static const _focusModeKey = 'isFocusModeEnabled';

  UserModel? _currentUser;
  bool _isLoading = false;

  // --- État du Mode Focus de l'IA avec Persistance ---
  // Initialisé à true, mais sera écrasé par la valeur sauvegardée au chargement.
  bool _isFocusModeEnabled = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isFocusModeEnabled => _isFocusModeEnabled;

  AuthViewModel() {
    // Lance la connexion et le chargement des préférences au démarrage.
    signIn();
  }

  // --- Méthodes d'Authentification et Chargement ---

  Future<void> signIn() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simuler la connexion de l'utilisateur
      _currentUser = await _repository.signInMockUser();

      // 1. Charger les deux préférences sauvegardées après la connexion
      await _loadFocusPreferences();
    } catch (e) {
      debugPrint('Erreur de connexion simulée : $e');
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- Méthode de Chargement des Préférences (Nouveau) ---

  Future<void> _loadFocusPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Charger le Temps de Focus
    // Valeur par défaut : 480 minutes (8 heures)
    final savedTime = prefs.getInt(_focusTimeKey) ?? 480;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(dailyFocusTime: savedTime);
    }

    // 2. Charger l'état du Mode Focus
    // Valeur par défaut : true (Activé)
    _isFocusModeEnabled = prefs.getBool(_focusModeKey) ?? true;

    final modeStr = _isFocusModeEnabled ? 'ON' : 'OFF';
    debugPrint(
        'Prefs chargées : FocusTime=$savedTime min, Mode Focus=$modeStr');
    // Pas besoin de notifyListeners ici car il est appelé juste après dans signIn()
  }

  // --- Méthodes de Mise à Jour et Sauvegarde du Profil ---

  // 1. Mise à jour du Temps de Focus (sauvegarde incluse)
  Future<void> updateDailyFocusTime(int newTimeInMinutes) async {
    if (_currentUser != null) {
      // Mettre à jour l'état
      _currentUser = _currentUser!.copyWith(dailyFocusTime: newTimeInMinutes);

      // Sauvegarder dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_focusTimeKey, newTimeInMinutes);

      notifyListeners();
      debugPrint(
          'Temps de concentration sauvegardé : $newTimeInMinutes minutes');
    }
  }

  // 2. Bascule du Mode Focus (sauvegarde incluse)
  Future<void> toggleFocusMode(bool isEnabled) async {
    if (_isFocusModeEnabled != isEnabled) {
      // Mettre à jour l'état
      _isFocusModeEnabled = isEnabled;

      // Sauvegarder dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_focusModeKey, isEnabled);

      // Notifie tous les widgets qui 'écoutent' cet état
      notifyListeners();
      final modeSaved = isEnabled ? 'Activé' : 'Désactivé';
      debugPrint('Mode Focus IA sauvegardé : $modeSaved');
    }
  }
}
