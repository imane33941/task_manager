import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences_provider.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'darkMode';

  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final isDark = prefs.getBool(_key) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final isDark = state == ThemeMode.dark;
    final newValue = !isDark;
    await prefs.setBool(_key, newValue);
    state = newValue ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
