// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import 'package:dogo_ai_assistant/main.dart';
import 'package:dogo_ai_assistant/view_models/theme_view_model.dart';
import 'package:dogo_ai_assistant/view_models/language_view_model.dart';
import 'package:dogo_ai_assistant/view_models/auth_view_model.dart';
import 'package:dogo_ai_assistant/view_models/task_view_model.dart';
import 'package:dogo_ai_assistant/views/screens/home/home_screen.dart';

void main() {
  testWidgets('App builds and shows HomeScreen (smoke test)',
      (WidgetTester tester) async {
    // Fournit les providers nécessaires pour que l'application se construise.
    // Pré-configure la locale en anglais pour éviter les erreurs de localisation
    final themeVm = ThemeViewModel();
    final langVm = LanguageViewModel();
    langVm.changeLanguage(const Locale('en', 'US'));
    final authVm = AuthViewModel();
    final taskVm = TaskViewModel();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeVm),
          ChangeNotifierProvider.value(value: langVm),
          ChangeNotifierProvider.value(value: authVm),
          ChangeNotifierProvider.value(value: taskVm),
        ],
        child: const DogoApp(),
      ),
    );

    // Laisser les microtasks et les opérations async initiales progresser
    // signInMockUser simule ~300ms, donc on pompe 500ms pour permettre l'init.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Vérifier qu'au moins HomeScreen est présent (smoke test simple)
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
