import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Tocke Brand (Magenta/Pink - 2026 Design)
  static const Color primary = Color(0xFFFF1F7D);
  static const Color primaryDark = Color(0xFFE50065);
  static const Color primaryLight = Color(0xFFFF59A1);

  // Secondary Colors - Verde Competencias
  static const Color secondary = Color(0xFF2a2a2a);
  static const Color secondaryDark = Color(0xFF1a1a1a);
  static const Color secondaryLight = Color(0xFF3a3a3a);

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

  // Background Colors - Dark theme (tocke-app-2026 style)
  static const Color background = Color(0xFF0a0a0a);
  static const Color backgroundDark = Color(0xFF0a0a0a);
  static const Color surface = Color(0xFF1a1a1a);
  static const Color surfaceDark = Color(0xFF1a1a1a);

  // Text Colors - Light text on dark background
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFa1a1a1);
  static const Color textDisabled = Color(0xFF6E6E6E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFa1a1a1);
  static const Color textDisabledDark = Color(0xFF6E6E6E);

  // Border Colors - Subtle borders on dark background
  static const Color border = Color(0xFF333333);
  static const Color borderDark = Color(0xFF1f1f1f);

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
