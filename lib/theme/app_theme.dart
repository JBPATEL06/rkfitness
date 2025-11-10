import 'package:flutter/material.dart';

final _kPrimaryRed = Colors.red.shade700;
final _kLightGrey = Colors.grey.shade200;

ThemeData appTheme(BuildContext context) {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      primary: _kPrimaryRed,
      secondary: Colors.black,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: Colors.black,
      error: Colors.red.shade900,
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: _kPrimaryRed,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimaryRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: _kLightGrey,
      labelStyle: base.textTheme.bodyLarge?.copyWith(
        color: Colors.black54,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _kPrimaryRed,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      showSelectedLabels: true,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.red.shade900,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}