import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AppFontWeight {
  extraBold,
  bold,
  semiBold,
  medium,
  regular,
  light,
  extraLight,
  thin,
}

class AppTextStyles {

  static TextStyle _base({
    required double size,
    required AppFontWeight weight,
    double letterSpacing = 0.5,
    double height = 1.2,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: size.sp,
      fontWeight: _mapWeight(weight),
      letterSpacing: letterSpacing,
      height: height,
      decoration: TextDecoration.none,
      fontStyle: FontStyle.normal,
    );
  }

  static FontWeight _mapWeight(AppFontWeight weight) {
    switch (weight) {
      case AppFontWeight.thin:
        return FontWeight.w100;
      case AppFontWeight.extraLight:
        return FontWeight.w200;
      case AppFontWeight.light:
        return FontWeight.w300;
      case AppFontWeight.regular:
        return FontWeight.w400;
      case AppFontWeight.medium:
        return FontWeight.w500;
      case AppFontWeight.semiBold:
        return FontWeight.w600;
      case AppFontWeight.bold:
        return FontWeight.w700;
      case AppFontWeight.extraBold:
        return FontWeight.w800;
    }
  }

  // Size definitions
  static TextStyle displayLarge(AppFontWeight weight) =>
      _base(size: 57, weight: weight, height: 1.12);

  static TextStyle headlineLarge(AppFontWeight weight) =>
      _base(size: 32, weight: weight, height: 1.25);

  static TextStyle headlineMedium(AppFontWeight weight) =>
      _base(size: 28, weight: weight, height: 1.27);

  static TextStyle titleLarge(AppFontWeight weight) =>
      _base(size: 22, weight: weight, height: 1.27);

  static TextStyle titleMedium(AppFontWeight weight) =>
      _base(size: 16, weight: weight, height: 1.5);

  static TextStyle bodyMedium(AppFontWeight weight) =>
      _base(size: 14, weight: weight, height: 1.43);

  static TextStyle bodySmall(AppFontWeight weight) =>
      _base(size: 12, weight: weight, height: 1.33);

  static TextStyle caption(AppFontWeight weight) =>
      _base(size: 10, weight: weight, height: 1.4);

  /*                               DISPLAY LARGE                                */

  static TextStyle get displayLargeExtraBold =>
      AppTextStyles.displayLarge(AppFontWeight.extraBold);

  static TextStyle get displayLargeBold =>
      AppTextStyles.displayLarge(AppFontWeight.bold);

  static TextStyle get displayLargeSemiBold =>
      AppTextStyles.displayLarge(AppFontWeight.semiBold);

  static TextStyle get displayLargeMedium =>
      AppTextStyles.displayLarge(AppFontWeight.medium);

  static TextStyle get displayLargeRegular =>
      AppTextStyles.displayLarge(AppFontWeight.regular);

  static TextStyle get displayLargeLight =>
      AppTextStyles.displayLarge(AppFontWeight.light);

  static TextStyle get displayLargeExtraLight =>
      AppTextStyles.displayLarge(AppFontWeight.extraLight);

  static TextStyle get displayLargeThin =>
      AppTextStyles.displayLarge(AppFontWeight.thin);

  /*                              HEADLINE LARGE                                 */

  static TextStyle get headlineLargeExtraBold =>
      AppTextStyles.headlineLarge(AppFontWeight.extraBold);

  static TextStyle get headlineLargeBold =>
      AppTextStyles.headlineLarge(AppFontWeight.bold);

  static TextStyle get headlineLargeSemiBold =>
      AppTextStyles.headlineLarge(AppFontWeight.semiBold);

  static TextStyle get headlineLargeMedium =>
      AppTextStyles.headlineLarge(AppFontWeight.medium);

  static TextStyle get headlineLargeRegular =>
      AppTextStyles.headlineLarge(AppFontWeight.regular);

  static TextStyle get headlineLargeLight =>
      AppTextStyles.headlineLarge(AppFontWeight.light);

  static TextStyle get headlineLargeExtraLight =>
      AppTextStyles.headlineLarge(AppFontWeight.extraLight);

  static TextStyle get headlineLargeThin =>
      AppTextStyles.headlineLarge(AppFontWeight.thin);

  /*                                HEADLINE MEDIUM                                   */    

  static TextStyle get headlineMediumExtraBold =>
      AppTextStyles.headlineMedium(AppFontWeight.extraBold);

  static TextStyle get headlineMediumBold =>
      AppTextStyles.headlineMedium(AppFontWeight.bold);   

  static TextStyle get headlineMediumSemiBold =>
      AppTextStyles.headlineMedium(AppFontWeight.semiBold);

  static TextStyle get headlineMediumMedium =>
      AppTextStyles.headlineMedium(AppFontWeight.medium);

  static TextStyle get headlineMediumRegular =>
      AppTextStyles.headlineMedium(AppFontWeight.regular);

  static TextStyle get headlineMediumLight =>
      AppTextStyles.headlineMedium(AppFontWeight.light);  

  static TextStyle get headlineMediumExtraLight =>
      AppTextStyles.headlineMedium(AppFontWeight.extraLight);

  static TextStyle get headlineMediumThin =>
      AppTextStyles.headlineMedium(AppFontWeight.thin);
  /*                                TITLE LARGE                                  */

  static TextStyle get titleLargeExtraBold =>
      AppTextStyles.titleLarge(AppFontWeight.extraBold);

  static TextStyle get titleLargeBold =>
      AppTextStyles.titleLarge(AppFontWeight.bold);

  static TextStyle get titleLargeSemiBold =>
      AppTextStyles.titleLarge(AppFontWeight.semiBold);

  static TextStyle get titleLargeMedium =>
      AppTextStyles.titleLarge(AppFontWeight.medium);

  static TextStyle get titleLargeRegular =>
      AppTextStyles.titleLarge(AppFontWeight.regular);

  static TextStyle get titleLargeLight =>
      AppTextStyles.titleLarge(AppFontWeight.light);

  static TextStyle get titleLargeExtraLight =>
      AppTextStyles.titleLarge(AppFontWeight.extraLight);

  static TextStyle get titleLargeThin =>
      AppTextStyles.titleLarge(AppFontWeight.thin);

  /*                               TITLE MEDIUM                                  */

  static TextStyle get titleMediumExtraBold =>
      AppTextStyles.titleMedium(AppFontWeight.extraBold);

  static TextStyle get titleMediumBold =>
      AppTextStyles.titleMedium(AppFontWeight.bold);

  static TextStyle get titleMediumSemiBold =>
      AppTextStyles.titleMedium(AppFontWeight.semiBold);

  static TextStyle get titleMediumMedium =>
      AppTextStyles.titleMedium(AppFontWeight.medium);

  static TextStyle get titleMediumRegular =>
      AppTextStyles.titleMedium(AppFontWeight.regular);

  static TextStyle get titleMediumLight =>
      AppTextStyles.titleMedium(AppFontWeight.light);

  static TextStyle get titleMediumExtraLight =>
      AppTextStyles.titleMedium(AppFontWeight.extraLight);

  static TextStyle get titleMediumThin =>
      AppTextStyles.titleMedium(AppFontWeight.thin);

  /*                               BODY MEDIUM                                   */

  static TextStyle get bodyMediumExtraBold =>
      AppTextStyles.bodyMedium(AppFontWeight.extraBold);

  static TextStyle get bodyMediumBold =>
      AppTextStyles.bodyMedium(AppFontWeight.bold);

  static TextStyle get bodyMediumSemiBold =>
      AppTextStyles.bodyMedium(AppFontWeight.semiBold);

  static TextStyle get bodyMediumMedium =>
      AppTextStyles.bodyMedium(AppFontWeight.medium);

  static TextStyle get bodyMediumRegular =>
      AppTextStyles.bodyMedium(AppFontWeight.regular);

  static TextStyle get bodyMediumLight =>
      AppTextStyles.bodyMedium(AppFontWeight.light);

  static TextStyle get bodyMediumExtraLight =>
      AppTextStyles.bodyMedium(AppFontWeight.extraLight);

  static TextStyle get bodyMediumThin =>
      AppTextStyles.bodyMedium(AppFontWeight.thin);

  /*                                BODY SMALL                                   */

  static TextStyle get bodySmallExtraBold =>
      AppTextStyles.bodySmall(AppFontWeight.extraBold);

  static TextStyle get bodySmallBold =>
      AppTextStyles.bodySmall(AppFontWeight.bold);

  static TextStyle get bodySmallSemiBold =>
      AppTextStyles.bodySmall(AppFontWeight.semiBold);

  static TextStyle get bodySmallMedium =>
      AppTextStyles.bodySmall(AppFontWeight.medium);

  static TextStyle get bodySmallRegular =>
      AppTextStyles.bodySmall(AppFontWeight.regular);

  static TextStyle get bodySmallLight =>
      AppTextStyles.bodySmall(AppFontWeight.light);

  static TextStyle get bodySmallExtraLight =>
      AppTextStyles.bodySmall(AppFontWeight.extraLight);

  static TextStyle get bodySmallThin =>
      AppTextStyles.bodySmall(AppFontWeight.thin);

  /*                                  CAPTION                                     */

  static TextStyle get captionExtraBold =>
      AppTextStyles.caption(AppFontWeight.extraBold);

  static TextStyle get captionBold =>
      AppTextStyles.caption(AppFontWeight.bold);

  static TextStyle get captionSemiBold =>
      AppTextStyles.caption(AppFontWeight.semiBold);

  static TextStyle get captionMedium =>
      AppTextStyles.caption(AppFontWeight.medium);

  static TextStyle get captionRegular =>
      AppTextStyles.caption(AppFontWeight.regular);

  static TextStyle get captionLight =>
      AppTextStyles.caption(AppFontWeight.light);

  static TextStyle get captionExtraLight =>
      AppTextStyles.caption(AppFontWeight.extraLight);

  static TextStyle get captionThin =>
      AppTextStyles.caption(AppFontWeight.thin);
}