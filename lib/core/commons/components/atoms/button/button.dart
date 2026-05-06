import 'package:flutter/material.dart';
import 'package:pasconnect/core/commons/components/atoms/colors/colors.dart';
import 'package:pasconnect/core/commons/components/atoms/text/text.dart';

class BaseButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final double height;
  final double? width;
  final bool isExpanded;
  final Color? textColor;
  final Widget? icon;
  final Color? buttonColor;
  final Color? disableButtonColor;
  final Color? borderColor;
  final FocusNode? focusNode;
  final ButtonType buttonType;
  final String? fontFamily;

  const BaseButton.filled({
    super.key,
    required this.text,
    this.isExpanded = true,
    this.textColor,
    required this.onPressed,
    this.height = 40,
    this.width,
    this.icon,
    this.borderColor,
    this.buttonColor,
    this.disableButtonColor,
    this.focusNode,
    this.fontFamily,
  }) : buttonType = ButtonType.filled;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor ?? AppColors.primaryButton,
        foregroundColor: textColor ?? AppColors.primaryText,
        disabledBackgroundColor: disableButtonColor ?? Colors.grey,
        minimumSize: Size(width ?? (isExpanded ? double.infinity : 0), height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      label: BaseText.bodyMediumRegular(
          text: text, textColor: textColor ?? AppColors.primaryText),
      icon: icon != null
          ? SizedBox(
              height: 16, width: 16, child: icon ?? const SizedBox.shrink())
          : const SizedBox.shrink(),
    );

    if (width != null || isExpanded) {
      return SizedBox(
        width: width ?? (isExpanded ? double.infinity : null),
        height: height,
        child: button,
      );
    }

    return button;
  }
}

enum ButtonType {filled}