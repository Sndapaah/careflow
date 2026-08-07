import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography ramp for CareFlow.
///
/// The mockups use a geometric sans with a tall x-height; Poppins is the
/// closest widely-available match. If the font cannot be fetched the app
/// degrades gracefully to the platform default rather than failing.
abstract final class AppTextStyles {
  static TextTheme textTheme() => GoogleFonts.poppinsTextTheme();

  // ------------------------------------------------------------- display
  /// "Welcome To CareFlow", "Sign Up" — the big centred brand headings.
  static TextStyle get display => GoogleFonts.poppins(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // ------------------------------------------------------------ headings
  /// Screen titles in the top bar.
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Section headers — "Facility Statistics", "Recommended Facilities (3)".
  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Card titles — facility names, "Possible Conditions".
  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Small all-caps labels — "WAIT", "CONFIDENCE", "MEDICAL INFORMATION".
  static TextStyle get overline => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.6,
    color: AppColors.textSecondary,
  );

  // ---------------------------------------------------------------- body
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMuted =>
      body.copyWith(color: AppColors.textSecondary);

  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textMuted,
  );

  // -------------------------------------------------------------- values
  /// The bold number in a statistic tile — "12", "18 min", "92%".
  static TextStyle get statValue => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get statLabel => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textMuted,
  );

  // ------------------------------------------------------------- actions
  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Chips, badges and pills — "Low Load", "TOP MATCH", "Emergency".
  static TextStyle get badge => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
