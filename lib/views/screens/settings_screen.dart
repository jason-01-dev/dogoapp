import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// --- Import des ViewModels requis pour les réglages ---
import '../../../../view_models/auth_view_model.dart';
import '../../../../view_models/theme_view_model.dart';
import '../../../../view_models/language_view_model.dart';
import '../../../../view_models/settings_view_model.dart';
import 'settings/map_picker_screen.dart';
// -----------------------------------------------------

// --- COULEURS GLOBALES ---
const Color kPrimaryColor = Color(0xFF2c3e50);
const Color kAccentColor = Color(0xFF1abc9c); // Vert Menthe

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _focusTimeController;

  @override
  void initState() {
    super.initState();

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    int initialMinutes = authViewModel.currentUser?.dailyFocusTime ?? 480;
    int initialHours = initialMinutes ~/ 60;

    _focusTimeController = TextEditingController(text: initialHours.toString());
  }

  @override
  void dispose() {
    _focusTimeController.dispose();
    super.dispose();
  }

  void _saveFocusTime() {
    final authViewModel = context.read<AuthViewModel>();
    final text = _focusTimeController.text;

    final hours = int.tryParse(text);
    if (hours == null || hours < 1 || hours > 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Veuillez entrer un nombre d\'heures valide (entre 1 et 18).')),
      );
      return;
    }

    final minutes = hours * 60;
    authViewModel.updateDailyFocusTime(minutes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Temps de concentration mis à jour à $hours heures.'),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final themeViewModel = context.watch<ThemeViewModel>();
    final languageViewModel = context.watch<LanguageViewModel>();
    final settingsViewModel = context.watch<SettingsViewModel>();

    final currentFocusTime = authViewModel.currentUser?.dailyFocusTime ?? 480;

    return Scaffold(
      appBar: AppBar(
        title: Text(languageViewModel.t('settings_title')),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              languageViewModel.t('preferences_language'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              title: Text(languageViewModel.t('app_language')),
              trailing: DropdownButton<Locale>(
                value: languageViewModel.appLocale,
                items: const [
                  DropdownMenuItem(
                      value: Locale('fr', 'FR'), child: Text('Français')),
                  DropdownMenuItem(
                      value: Locale('en', 'US'), child: Text('English')),
                ],
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    languageViewModel.changeLanguage(newLocale);
                  }
                },
              ),
            ),
            const Divider(height: 30),

            const Text(
              'Thème de l\'application',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Mode sombre'),
              trailing: Switch(
                value: themeViewModel.isDarkMode,
                onChanged: (isDark) {
                  final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
                  themeViewModel.setThemeMode(newMode);
                },
                thumbColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return kAccentColor;
                  }
                  return null;
                }),
                trackColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return kAccentColor.withAlpha((0.5 * 255).round());
                  }
                  return null;
                }),
              ),
            ),
            const Divider(height: 50),

            const Text(
              'Mode Focus Quotidien (Le Cœur de DoGo)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Ce paramètre est utilisé par l\'IA pour filtrer et prioriser les tâches pour votre journée. DoGo ne vous montrera que le travail qu\'il estime pouvoir être complété dans ce temps.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            const Text('Temps maximal de concentration (en heures):',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _focusTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Heures',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kAccentColor, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: kAccentColor.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: kAccentColor.withAlpha((0.5 * 255).round())),
                  ),
                  child: Text(
                    '$currentFocusTime minutes',
                    style: const TextStyle(
                        color: kAccentColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveFocusTime,
                icon: const Icon(Icons.save),
                label: const Text('Sauvegarder le Temps de Focus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const Divider(height: 30),

            // Notifications section
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(languageViewModel.t('enable_notifications')),
              subtitle: Text(languageViewModel.t('reminders')),
              value: settingsViewModel.notificationsEnabled,
              onChanged: (v) => settingsViewModel.setNotificationsEnabled(v),
            ),
            const SizedBox(height: 8),
            const Text('Rappels automatiques',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            CheckboxListTile(
              title: const Text('1 heure avant'),
              value: settingsViewModel.reminder1h,
              onChanged: (v) => settingsViewModel.setReminder1h(v ?? false),
            ),
            CheckboxListTile(
              title: const Text('30 minutes avant'),
              value: settingsViewModel.reminder30m,
              onChanged: (v) => settingsViewModel.setReminder30m(v ?? false),
            ),
            CheckboxListTile(
              title: const Text('10 minutes avant'),
              value: settingsViewModel.reminder10m,
              onChanged: (v) => settingsViewModel.setReminder10m(v ?? false),
            ),
            CheckboxListTile(
              title: const Text('5 minutes avant'),
              value: settingsViewModel.reminder5m,
              onChanged: (v) => settingsViewModel.setReminder5m(v ?? false),
            ),

            const Divider(height: 20),

            Text(
              languageViewModel.t('default_address'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              settingsViewModel.selectedAddress ??
                  'Aucune adresse sélectionnée',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: Text(languageViewModel.t('choose_from_map')),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                          builder: (_) => const MapPickerScreen()),
                    );
                    if (!mounted) return;
                    if (result != null) {
                      await settingsViewModel.setAddressFromMap(result);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Adresse sélectionnée : $result')),
                      );
                    }
                  },
                ),
                const SizedBox(width: 12),
                if (settingsViewModel.selectedAddress != null &&
                    settingsViewModel.selectedAddress!.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await settingsViewModel.setAddressFromMap('');
                    },
                    child: const Text('Supprimer'),
                  ),
              ],
            ),

            const Divider(height: 50),

            const Text(
              'Contrôle du Flux de Travail',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Activer le Mode Focus IA'),
              subtitle:
                  const Text('Désactiver l\'IA pour ne pas filtrer vos tâches'),
              trailing: Switch(
                value: authViewModel.isFocusModeEnabled,
                onChanged: (bool value) {
                  authViewModel.toggleFocusMode(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
