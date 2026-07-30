import 'package:flutter/material.dart';

/// Single source of truth for every colour used in the CareFlow UI.
///
/// Nothing outside this file should hard-code a [Color] literal.
abstract final class AppColors {
  // ---------------------------------------------------------------- brand
  /// Primary action blue — filled buttons, links, active nav items.
  static const Color primary = Color(0xFF2E7CF6);
  static const Color primaryDark = Color(0xFF1B5FD4);
  static const Color primarySoft = Color(0xFFCFE0FD);
  static const Color primarySurface = Color(0xFFDCE9FE);

  /// Secondary cyan — the "CareFlow" wordmark, onboarding accents, icon tints.
  static const Color accent = Color(0xFF15C7EB);
  static const Color accentDark = Color(0xFF0EA5C6);
  static const Color accentSoft = Color(0xFFD5F4FB);
  static const Color accentSurface = Color(0xFFE7F8FD);

  // ----------------------------------------------------------- backgrounds
  /// App-wide page background — a very pale blue tint, not pure white.
  static const Color background = Color(0xFFF0F6FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF6F8FA);
  static const Color mapSurface = Color(0xFFE9EDF0);

  // ------------------------------------------------------------------ text
  static const Color textPrimary = Color(0xFF0C1116);
  static const Color textSecondary = Color(0xFF5C6672);
  static const Color textMuted = Color(0xFF9AA4B0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // --------------------------------------------------------------- borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // -------------------------------------------------------- status: green
  /// "Low Load", confidence scores, checkmarks, health tips.
  static const Color success = Color(0xFF16A34A);
  static const Color successText = Color(0xFF1B9E58);
  static const Color successSurface = Color(0xFFD8F5E3);
  static const Color successSurfaceSoft = Color(0xFFE4F5E9);

  // ------------------------------------------------------- status: yellow
  /// "Medium Load".
  static const Color warning = Color(0xFFB08900);
  static const Color warningSurface = Color(0xFFFBF3C6);

  // ---------------------------------------------------------- status: red
  /// Emergency badges, sign-out, severity alerts, the logo cross.
  static const Color danger = Color(0xFFE6362F);
  static const Color dangerSurface = Color(0xFFFCDCDC);
  static const Color dangerSurfaceSoft = Color(0xFFFDF1F1);

  // ---------------------------------------------------------- misc / logo
  static const Color logoPinTop = Color(0xFF2BB7E8);
  static const Color logoPinBottom = Color(0xFF1447C4);
  static const Color logoBase = Color(0xFF0B1F63);
  static const Color star = Color(0xFFFFC91E);

  static const Color googleRed = Color(0xFFEA4335);
  static const Color facebookBlue = Color(0xFF1877F2);

  // --------------------------------------------------------------- shadow
  static const Color shadow = Color(0x14101828);
  static const Color shadowStrong = Color(0x1F101828);
}
