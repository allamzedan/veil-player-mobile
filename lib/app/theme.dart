import 'package:flutter/material.dart';

/// Dark Material 3 theme for VEIL Mobile.
final ThemeData veilDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF5B6EE8),
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 1,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias,
  ),
  navigationBarTheme: NavigationBarThemeData(
    elevation: 0,
    height: 72,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    indicatorShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
  ),
);
