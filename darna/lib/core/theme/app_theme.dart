import 'package:flutter/material.dart';

/// Warm rose palette: soft pinks and peach on a cream background,
/// meant to feel welcoming and trustworthy.
class AppColors {
  static const rose = Color(0xFFD9576B); // primary
  static const roseDark = Color(0xFFB03E54);
  static const blush = Color(0xFFFFE3E6); // primary container
  static const peach = Color(0xFFF4A38B); // secondary
  static const peachLight = Color(0xFFFFE9DF);
  static const cream = Color(0xFFFFF8F5); // background
  static const plum = Color(0xFF3D2A30); // text
  static const muted = Color(0xFF8A7276);
  static const success = Color(0xFF4E9F76);
  static const warning = Color(0xFFE0A030);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE56F84), Color(0xFFF4A38B)],
  );
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.rose,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.rose,
      onPrimary: Colors.white,
      primaryContainer: AppColors.blush,
      onPrimaryContainer: AppColors.roseDark,
      secondary: AppColors.peach,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.peachLight,
      onSecondaryContainer: const Color(0xFF7A3B26),
      surface: AppColors.cream,
      onSurface: AppColors.plum,
      onSurfaceVariant: AppColors.muted,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFFF3EF),
      surfaceContainer: const Color(0xFFFCEDE9),
      surfaceContainerHigh: const Color(0xFFF9E6E2),
      outline: const Color(0xFFE2CACC),
      outlineVariant: const Color(0xFFF0DEDF),
    );

    final rounded16 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.plum,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.plum,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFF3E1E2)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEBD6D8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEBD6D8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.rose, width: 1.6),
        ),
        prefixIconColor: AppColors.muted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: rounded16,
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: rounded16,
          foregroundColor: AppColors.rose,
          side: const BorderSide(color: AppColors.rose),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.roseDark),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.blush,
        side: const BorderSide(color: Color(0xFFEBD6D8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(color: AppColors.plum),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.blush,
          selectedForegroundColor: AppColors.roseDark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.blush,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? AppColors.roseDark
                : AppColors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.roseDark
                : AppColors.muted,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.rose,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.plum,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFF0DEDF)),
    );
  }
}
