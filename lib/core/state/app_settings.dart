import 'package:flutter/material.dart';

/// Estado global simple de la app (sin paquetes externos).
///
/// Guarda el modo de tema (claro/oscuro) y si el usuario es PRO. Los widgets
/// que necesiten reaccionar escuchan con `ListenableBuilder`.
class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void setDarkMode(bool on) {
    final next = on ? ThemeMode.dark : ThemeMode.light;
    if (next == _themeMode) return;
    _themeMode = next;
    notifyListeners();
  }

  bool _isPro = false;
  bool get isPro => _isPro;

  void setPro(bool value) {
    if (value == _isPro) return;
    _isPro = value;
    notifyListeners();
  }
}
