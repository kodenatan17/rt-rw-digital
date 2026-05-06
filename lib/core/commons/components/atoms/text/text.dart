import 'package:flutter/material.dart';
import 'package:pasconnect/core/commons/components/atoms/typography/text_styles.dart';

class BaseText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final int? maxLines;
  final Color textColor;
  final TextDecoration? textDecoration;
  final double? letterSpacing;

  BaseText.displayLargeExtraBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.displayLargeExtraBold;

  BaseText.displayLargeBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.displayLargeBold;

  BaseText.displayLargeSemiBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.displayLargeSemiBold;

  BaseText.displayLargeMedium({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.displayLargeMedium;

  BaseText.displayLargeRegular({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.displayLargeRegular;

  BaseText.displayLargeLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.displayLargeLight;

  BaseText.displayLargeExtraLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.displayLargeExtraLight;

  BaseText.displayLargeThin({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.displayLargeThin;

  BaseText.headlineLargeExtraBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineLargeExtraBold;

  BaseText.headlineLargeBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineLargeBold;

  BaseText.headlineLargeSemiBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.letterSpacing,
    this.textDecoration,
  }) : textStyle = AppTextStyles.headlineLargeSemiBold;

  BaseText.headlineLargeMedium({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineLargeMedium;

  BaseText.headlineLargeRegular({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineLargeRegular;

  BaseText.headlineLargeLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineLargeLight;

  BaseText.headlineLargeExtraLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineLargeExtraLight;

  BaseText.headlineLargeThin({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineLargeThin;

  BaseText.headlineMediumExtraBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineMediumExtraBold;

  BaseText.headlineMediumBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineMediumBold;

  BaseText.headlineMediumSemiBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineMediumSemiBold;

  BaseText.headlineMediumMedium({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineMediumMedium;

  BaseText.headlineMediumRegular({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineMediumRegular;

  BaseText.headlineMediumLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineMediumLight;

  BaseText.headlineMediumExtraLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.headlineMediumExtraLight;

  BaseText.titleLargeExtraBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleLargeExtraBold;

  BaseText.titleLargeBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleLargeBold;

  BaseText.titleLargeSemiBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleLargeSemiBold;

  BaseText.titleLargeMedium({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleLargeMedium;

  BaseText.titleLargeRegular({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleLargeRegular;

  BaseText.titleLargeLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleLargeLight;

  BaseText.titleLargeExtraLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleLargeExtraLight;

  BaseText.titleLargeThin({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleLargeThin;

  BaseText.titleMediumExtraBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleMediumExtraBold;

  BaseText.titleMediumBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleMediumBold;

  BaseText.titleMediumSemiBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleMediumSemiBold;

  BaseText.titleMediumMedium({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleMediumMedium;

  BaseText.titleMediumRegular({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleMediumRegular;

  BaseText.titleMediumLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleMediumLight;

  BaseText.titleMediumExtraLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleMediumExtraLight;

  BaseText.titleMediumThin({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.titleMediumThin;

  BaseText.bodyMediumExtraBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodyMediumExtraBold;

  BaseText.bodyMediumBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodyMediumBold;

  BaseText.bodyMediumSemiBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodyMediumSemiBold;

  BaseText.bodyMediumMedium({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodyMediumMedium;

  BaseText.bodyMediumRegular({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodyMediumRegular;

  BaseText.bodyMediumLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodyMediumLight;

  BaseText.bodyMediumExtraLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodyMediumExtraLight;

  BaseText.bodyMediumThin({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodyMediumThin;

  BaseText.bodySmallExtraBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodySmallExtraBold;

  BaseText.bodySmallBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodySmallBold;

  BaseText.bodySmallSemiBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodySmallSemiBold;

  BaseText.bodySmallMedium({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodySmallMedium;

  BaseText.bodySmallRegular({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodySmallRegular;

  BaseText.bodySmallLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodySmallLight;

  BaseText.bodySmallExtraLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodySmallExtraLight;

  BaseText.bodySmallThin({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.bodySmallThin;

  BaseText.captionExtraBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.captionExtraBold;

  BaseText.captionBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.captionBold;

  BaseText.captionSemiBold({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.captionSemiBold;

  BaseText.captionMedium({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.captionMedium;

  BaseText.captionRegular({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.captionRegular;

  BaseText.captionThin({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.captionThin;

  BaseText.captionExtraLight({
    super.key,
    required this.text,
    this.textAlign,
    this.textOverflow,
    this.maxLines,
    required this.textColor,
    this.textDecoration,
    this.letterSpacing,
  }) : textStyle = AppTextStyles.captionExtraLight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: textOverflow,
      style: textStyle.copyWith(
        color: textColor,
        decoration: textDecoration,
        letterSpacing: letterSpacing,
      ),
      softWrap: true,
    );
  }
}
