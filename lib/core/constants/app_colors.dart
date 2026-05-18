import 'package:flutter/material.dart';

/// SoulGuide Design System - Color Palette
/// Source: SoulGuide DESIGN.md + ana_ekran_soft_pastel/code.html
class AppColors {
  AppColors._();

  // === BACKGROUND & SURFACE ===
  static const Color background = Color(0xFF111316);
  static const Color surface = Color(0xFF111316);
  static const Color surfaceDim = Color(0xFF111316);
  static const Color surfaceBright = Color(0xFF37393D);
  static const Color surfaceContainerLowest = Color(0xFF0C0E11);
  static const Color surfaceContainerLow = Color(0xFF1A1C1F);
  static const Color surfaceContainer = Color(0xFF1E2023);
  static const Color surfaceContainerHigh = Color(0xFF282A2D);
  static const Color surfaceContainerHighest = Color(0xFF333538);
  static const Color surfaceVariant = Color(0xFF333538);

  // === ON-SURFACE ===
  static const Color onBackground = Color(0xFFE2E2E6);
  static const Color onSurface = Color(0xFFE2E2E6);
  static const Color onSurfaceVariant = Color(0xFFC3C6CF);
  static const Color inverseSurface = Color(0xFFE2E2E6);
  static const Color inverseOnSurface = Color(0xFF2F3034);

  // === PRIMARY (Powder Blue) ===
  static const Color primary = Color(0xFFE5EEFF);
  static const Color onPrimary = Color(0xFF0C3254);
  static const Color primaryContainer = Color(0xFFB4D4FF);
  static const Color onPrimaryContainer = Color(0xFF3C5C81);
  static const Color primaryFixed = Color(0xFFD2E4FF);
  static const Color primaryFixedDim = Color(0xFFA9C9F3);
  static const Color onPrimaryFixed = Color(0xFF001C37);
  static const Color onPrimaryFixedVariant = Color(0xFF28496C);
  static const Color inversePrimary = Color(0xFF416086);
  static const Color surfaceTint = Color(0xFFA9C9F3);

  // === SECONDARY (Soft Lilac) ===
  static const Color secondary = Color(0xFFD2BFE7);
  static const Color onSecondary = Color(0xFF382A4A);
  static const Color secondaryContainer = Color(0xFF4F4062);
  static const Color onSecondaryContainer = Color(0xFFC0AED5);
  static const Color secondaryFixed = Color(0xFFEEDCFF);
  static const Color secondaryFixedDim = Color(0xFFD2BFE7);
  static const Color onSecondaryFixed = Color(0xFF221534);
  static const Color onSecondaryFixedVariant = Color(0xFF4F4062);

  // === TERTIARY (Mint Green) ===
  static const Color tertiary = Color(0xFFCEF7DE);
  static const Color onTertiary = Color(0xFF123726);
  static const Color tertiaryContainer = Color(0xFFB2DBC2);
  static const Color onTertiaryContainer = Color(0xFF3D614E);
  static const Color tertiaryFixed = Color(0xFFC3ECD3);
  static const Color tertiaryFixedDim = Color(0xFFA7D0B8);
  static const Color onTertiaryFixed = Color(0xFF002113);
  static const Color onTertiaryFixedVariant = Color(0xFF294E3C);

  // === ERROR ===
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // === OUTLINE ===
  static const Color outline = Color(0xFF8D9199);
  static const Color outlineVariant = Color(0xFF43474E);

  // === GLASS CARD ===
  static const Color glassCardBackground = Color(0x66282A2D); // rgba(40,42,45,0.4)
  static const Color glassCardBorder = Color(0x1AFFFFFF);    // rgba(255,255,255,0.1)

  // === GRADIENT HELPERS ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCEF7DE), Color(0xFFA9C9F3)],
  );

  static const LinearGradient radarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x99B4D4FF), Color(0x33D2BFE7)],
  );

  static const RadialGradient backgroundGradient = RadialGradient(
    center: Alignment(-1.0, -1.0),
    radius: 1.5,
    colors: [Color(0x26416086), Color(0x00111316)],
  );
}
