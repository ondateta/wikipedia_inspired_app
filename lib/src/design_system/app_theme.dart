import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryLight = Color(0xFF0A84FF);
  static const Color primaryDark = Color(0xFF0A84FF);
  
  static const Color secondaryLight = Color(0xFF34C759);
  static const Color secondaryDark = Color(0xFF30D158);
  
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Colors.black;
  
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Colors.black;
  static const Color surfaceContainerLight = Color(0xFFF1F1F1);
  static const Color surfaceContainerDark = Color(0xFF181818);
  
  static const Color textLight = Colors.black;
  static const Color textDark = Colors.white;
  
  static const Color errorLight = Colors.red;
  static const Color errorDark = Colors.red;
  
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 24.0;
  
  static const double paddingSmall = 8.0;
  static const double paddingRegular = 16.0;
  static const double paddingMedium = 24.0;
  static const double paddingLarge = 32.0;
  
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusRegular = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  
  static const double elevationSmall = 2.0;
  static const double elevationRegular = 4.0;
  static const double elevationMedium = 8.0;
  static const double elevationLarge = 16.0;
  
  static ThemeData getLightTheme() {
    return ThemeData(
      fontFamily: 'Wanted Sans',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: primaryLight,
        primary: primaryLight,
        secondary: secondaryLight,
        surface: surfaceLight,
        onSurface: textLight,
        inverseSurface: textDark,
        surfaceContainer: surfaceContainerLight,
        surfaceTint: Colors.transparent,
        error: errorLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(textLight),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: backgroundLight,
        foregroundColor: textLight,
      ),
      iconTheme: const IconThemeData(
        color: textLight,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: surfaceContainerLight,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        bodySmall: TextStyle(fontSize: fontSizeSmall, color: textLight),
        bodyMedium: TextStyle(fontSize: fontSizeRegular, color: textLight),
        bodyLarge: TextStyle(fontSize: fontSizeMedium, color: textLight),
        titleSmall: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.bold, color: textLight),
        titleMedium: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.bold, color: textLight),
        titleLarge: TextStyle(fontSize: fontSizeXLarge, fontWeight: FontWeight.bold, color: textLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevationSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusRegular),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: paddingRegular,
            vertical: paddingSmall,
          ),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      fontFamily: 'Wanted Sans',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: primaryDark,
        primary: primaryDark,
        secondary: secondaryDark,
        surface: surfaceDark,
        onSurface: textDark,
        inverseSurface: textLight,
        surfaceContainer: surfaceContainerDark,
        surfaceTint: Colors.transparent,
        error: errorDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(textDark),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: backgroundDark,
        foregroundColor: textDark,
      ),
      iconTheme: const IconThemeData(
        color: textDark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: surfaceContainerDark,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        bodySmall: TextStyle(fontSize: fontSizeSmall, color: textDark),
        bodyMedium: TextStyle(fontSize: fontSizeRegular, color: textDark),
        bodyLarge: TextStyle(fontSize: fontSizeMedium, color: textDark),
        titleSmall: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.bold, color: textDark),
        titleMedium: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.bold, color: textDark),
        titleLarge: TextStyle(fontSize: fontSizeXLarge, fontWeight: FontWeight.bold, color: textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevationSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusRegular),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: paddingRegular,
            vertical: paddingSmall,
          ),
        ),
      ),
    );
  }
}