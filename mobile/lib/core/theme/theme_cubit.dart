import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _keyTheme = 'battwaa_theme_mode';

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mode = prefs.getString(_keyTheme);
      if (mode == 'dark') {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.light);
      }
    } catch (_) {}
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.dark) {
      emit(ThemeMode.light);
      await prefs.setString(_keyTheme, 'light');
    } else {
      emit(ThemeMode.dark);
      await prefs.setString(_keyTheme, 'dark');
    }
  }

  void setTheme(ThemeMode mode) async {
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
