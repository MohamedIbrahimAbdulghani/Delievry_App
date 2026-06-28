import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences sharedPreferences;

  SettingsCubit({required this.sharedPreferences})
      : super(const SettingsState(
          themeMode: ThemeMode.light,
          locale: Locale('en'),
        )) {
    _loadSettings();
  }

  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';

  void _loadSettings() {
    final themeIndex = sharedPreferences.getInt(_themeKey) ?? ThemeMode.light.index;
    final localeCode = sharedPreferences.getString(_localeKey) ?? 'en';

    emit(state.copyWith(
      themeMode: ThemeMode.values[themeIndex],
      locale: Locale(localeCode),
    ));
  }

  void toggleTheme() {
    final newTheme = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    sharedPreferences.setInt(_themeKey, newTheme.index);
    emit(state.copyWith(themeMode: newTheme));
  }

  void toggleLocale() {
    final newLocale = state.locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    sharedPreferences.setString(_localeKey, newLocale.languageCode);
    emit(state.copyWith(locale: newLocale));
  }
}
