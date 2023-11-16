import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;
  bool get isDarkMode => _isDarkMode; // Getter untuk isDarkMode

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Definisikan ThemeData untuk Mode Terang dan Mode Malam di sini
  final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.indigo,
    // Atur properti tema mode terang
    brightness: Brightness.light,
    // ... (atur properti lainnya)
  );

  final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.indigo,
    // Atur properti tema mode gelap
    brightness: Brightness.dark,
    // ... (atur properti lainnya)
  );
}
