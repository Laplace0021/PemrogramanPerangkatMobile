import 'package:flutter/material.dart';

class Themeprovider with ChangeNotifier{ 
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(){
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}