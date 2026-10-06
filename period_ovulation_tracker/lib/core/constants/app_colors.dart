import 'package:flutter/material.dart';

abstract final class AppColors {
  // ============================================================
  // Brand
  // ============================================================

  /// Core warm rose
  static const Color primary = Color(0xFFE85078);

  /// Ultra-soft tinted container background
  static const Color primaryLight = Color(0xFFFDF0F3);

  /// Secondary rose for badges & secondary highlights
  static const Color secondary = Color(0xFFF07293);

  /// High-emphasis vibrant coral
  static const Color accent = Color(0xFFE03856);

  // ============================================================
  // Neutral (High Contrast)
  // ============================================================

  /// Warm, clean canvas background
  static const Color background = Color(0xFFFAF7F8);

  /// Pure white for cards & elevated elements
  static const Color surface = Color(0xFFFFFFFF);

  /// Deep slate-charcoal for crisp readability (passes WCAG AAA)
  static const Color textPrimary = Color(0xFF1E1719);

  /// Neutral slate-gray for clear subheaders & metadata
  static const Color textSecondary = Color(0xFF6B5E63);

  /// Subtle border & divider color
  static const Color border = Color(0xFFEEDFE3);

  // ============================================================
  // Health & Cycle States (Distinct Hues)
  // ============================================================

  /// Menstrual / Period (Vibrant Berry Crimson)
  static const Color period = Color(0xFFE53958);

  /// Ovulation / Peak (Warm Golden Amber)
  static const Color ovulation = Color(0xFFF59E0B);

  /// Fertility / Conception Window (Soft Royal Violet)
  static const Color fertility = Color(0xFF8B5CF6);

  /// Pregnancy (Calm Sage Green)
  static const Color pregnancy = Color(0xFF10B981);

  /// Perimenopause / Transition (Warm Rose-Plum)
  static const Color perimenopause = Color(0xFFA85597);

  // ============================================================
  // Feedback
  // ============================================================

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // ============================================================
  // Dark mode
  // ============================================================

  static const Color darkBackground = Color(0xFF140F11);
  static const Color darkSurface = Color(0xFF221A1E);
  static const Color darkPrimary = Color(0xFFF47294);
  static const Color darkTextPrimary = Color(0xFFF9F5F6);
  static const Color darkTextSecondary = Color(0xFFB5A7AC);
  static const Color darkBorder = Color(0xFF382B31);

  // ============================================================
  // Dark Health States
  // ============================================================

  static const Color darkPeriod = Color(0xFFFF5472);
  static const Color darkOvulation = Color(0xFFFBBF24);
  static const Color darkFertility = Color(0xFFA78BFA);
  static const Color darkPregnancy = Color(0xFF34D399);
  static const Color darkPerimenopause = Color(0xFFC084FC);

  // ============================================================
  // Common
  // ============================================================

  static const Color transparent = Colors.transparent;

  // ============================================================
  // Gradients
  // ============================================================

  static const LinearGradient appGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, Color(0xFFFFF9FA), surface],
  );

  static const LinearGradient periodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE85078), Color(0xFFD83152)],
  );

  static const LinearGradient fertilityGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  );

  static const LinearGradient ovulationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient pregnancyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
}
