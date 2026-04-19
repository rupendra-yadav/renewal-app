import 'package:flutter/material.dart';

/// Central place for every design token in RenewTrack.
abstract class AppColors {
  static const primary = Color(0xFF534AB7);
  static const primaryLight = Color(0xFF7B74CC);
  static const primaryDark = Color(0xFF3B3490);
  static const background = Color(0xFFF7F6FF);
  static const surface = Colors.white;
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFF57C00);
  static const success = Color(0xFF2E7D32);
  static const expired = Color(0xFFFFEBEE);
  static const expiredText = Color(0xFFD32F2F);
  static const dueSoon = Color(0xFFFFF3E0);
  static const dueSoonText = Color(0xFFE65100);
  static const active = Color(0xFFE8F5E9);
  static const activeText = Color(0xFF1B5E20);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B6B8A);
  static const divider = Color(0xFFE0DFF5);
  static const cardBorder = Color(0xFFEAE9F8);
}

abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

abstract class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 100;
}

abstract class AppTextSize {
  static const double xs = 10;
  static const double sm = 12;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 18;
  static const double xxl = 22;
  static const double xxxl = 28;
}

abstract class AppTheme {
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Nunito',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: AppTextSize.xxxl,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary),
        titleLarge: TextStyle(
            fontSize: AppTextSize.xl,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
        titleMedium: TextStyle(
            fontSize: AppTextSize.lg,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        bodyLarge: TextStyle(
            fontSize: AppTextSize.md,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary),
        bodyMedium: TextStyle(
            fontSize: AppTextSize.sm,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary),
        labelSmall: TextStyle(
            fontSize: AppTextSize.xs,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(
            color: AppColors.textSecondary, fontSize: AppTextSize.md),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(
              fontSize: AppTextSize.lg, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(
              fontSize: AppTextSize.lg, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(
            fontSize: AppTextSize.sm, fontWeight: FontWeight.w500),
        side: const BorderSide(color: AppColors.cardBorder),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                color: AppColors.primary,
                fontSize: AppTextSize.xs,
                fontWeight: FontWeight.w600);
          }
          return const TextStyle(
              color: AppColors.textSecondary, fontSize: AppTextSize.xs);
        }),
        elevation: 4,
        shadowColor: AppColors.primary.withOpacity(0.08),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
