import 'package:flutter/material.dart';

/// 🎨 Glamora Official Color Palette
class GlamoraColors {
  static const Color midnightBlue = Color(0xFF0B1739);  // Primary background
  static const Color deepNavy = Color(0xFF13224F);      // Gradient secondary
  static const Color creamBeige = Color(0xFFF6EFD9);    // Accent / buttons
  static const Color softWhite = Color.fromRGBO(255, 255, 255, 0.08); // Cards
}

/// 🧵 Centralized ThemeData for the Glamora app
final ThemeData glamoraTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: GlamoraColors.midnightBlue,
  colorScheme: ColorScheme.dark(
    primary: GlamoraColors.creamBeige,
    secondary: GlamoraColors.deepNavy,
    background: GlamoraColors.midnightBlue,
  ),

  // 🏷️ AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: GlamoraColors.midnightBlue,
    titleTextStyle: TextStyle(
      color: GlamoraColors.creamBeige,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.1,
    ),
    iconTheme: IconThemeData(color: GlamoraColors.creamBeige),
    elevation: 0,
  ),

  // ✍️ Text
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: Colors.white70,
      fontSize: 16,
    ),
    titleLarge: TextStyle(
      color: GlamoraColors.creamBeige,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
  ),

  // 🔘 Buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: GlamoraColors.creamBeige,
      foregroundColor: GlamoraColors.midnightBlue,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: GlamoraColors.creamBeige,
    foregroundColor: GlamoraColors.midnightBlue,
  ),
);
