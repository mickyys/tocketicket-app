import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Tocke Brand (Magenta)
  static const Color primary = Color(0xFFE50065);
  static const Color primaryDark = Color(0xFFB8004D);
  static const Color primaryLight = Color(0xFFFF4D99);

  // Secondary Colors - Verde Competencias
  static const Color secondary = Color(0xFF00994D);
  static const Color secondaryDark = Color(0xFF007A3D);
  static const Color secondaryLight = Color(0xFF00C15A);

  // Timer Banner Color - Variante Verde
  static const Color timerBanner = Color(0xFF00C15A);

  // Validation Colors
  static const Color success = Color(0xFF00994D);
  static const Color successLight = Color(0xFF00C15A);
  static const Color successDark = Color(0xFF007A3D);

  static const Color error = Color(0xFFE50065);
  static const Color errorLight = Color(0xFFFF4D99);
  static const Color errorDark = Color(0xFFB8004D);

  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFFF8F00);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);
  static const Color grey = Color(0xFF6E6E6E);
  static const Color greyLight = Color(0xFFE2E2E2);
  static const Color greyDark = Color(0xFF424242);

  // Background Colors
  static const Color background = Color(0xFFF8F8F8);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color textDisabled = Color(0xFFE2E2E2);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF6E6E6E);
  static const Color textDisabledDark = Color(0xFFE2E2E2);

  // Border Colors
  static const Color border = Color(0xFFE2E2E2);
  static const Color borderDark = Color(0xFF424242);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);

  // QR Scanner Colors
  static const Color scannerOverlay = Color(0x80000000);
  static const Color scannerFrame = Color(0xFFFFFFFF);
  static const Color scannerCorner = Color(0xFFE50065);
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  static const LinearGradient secondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondary, AppColors.secondaryDark],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.success, AppColors.successDark],
  );

  static const LinearGradient error = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.error, AppColors.errorDark],
  );
}
