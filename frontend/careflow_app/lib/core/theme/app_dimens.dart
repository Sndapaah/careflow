import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spacing scale. Every gap in the UI should come from here.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Horizontal page gutter used by every screen.
  static const double gutter = 20;

  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: gutter);
}

/// Corner radii.
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius cardLarge = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius field = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rounded = BorderRadius.all(Radius.circular(pill));
}

/// Reusable elevation presets, tuned to the soft shadows in the designs.
abstract final class AppShadows {
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> subtle = <BoxShadow>[
    BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> sheet = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadowStrong,
      blurRadius: 24,
      offset: Offset(0, -6),
    ),
  ];

  static const List<BoxShadow> button = <BoxShadow>[
    BoxShadow(color: Color(0x332E7CF6), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
