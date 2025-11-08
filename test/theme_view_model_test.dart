import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogo_ai_assistant/view_models/theme_view_model.dart';
import 'package:flutter/material.dart';

void main() {
  setUp(() async {
    // Clear shared preferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  test('ThemeViewModel saves and loads theme mode', () async {
    // Ensure prefs start empty
    SharedPreferences.setMockInitialValues({});

    final vm = ThemeViewModel();

    // By default the theme should be system
    expect(vm.themeMode, equals(ThemeMode.system));

    // Set to dark
    vm.setThemeMode(ThemeMode.dark);

    // Wait a small amount to allow async save to complete
    await Future.delayed(const Duration(milliseconds: 50));

    // Create a new instance and load from prefs
    final vm2 = ThemeViewModel();
    await vm2.loadThemeMode();

    expect(vm2.themeMode, equals(ThemeMode.dark));
  });
}
