import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.light,
    ).copyWith(error: Colors.red, onError: Colors.white),

    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.dark,
    ).copyWith(error: Colors.red, onError: Colors.white),

    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );
}
