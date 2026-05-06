import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasconnect/core/commons/components/atoms/colors/colors.dart';
import 'package:pasconnect/core/commons/components/atoms/text/text.dart';
import 'package:pasconnect/core/commons/components/atoms/typography/text_styles.dart';

class BaseTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final int? maxLength;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? borderColor;
  final List<TextInputFormatter>? inputFormatters;

  const BaseTextField({
    super.key,
    this.label,
    this.hintText,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.maxLength,
    this.backgroundColor,
    this.textColor,
    this.hintColor,
    this.borderColor,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    // Build combined prefixIcon widget if prefixText is provided
    Widget? combinedPrefixIcon;
    if (prefixText != null || prefixIcon != null) {
      combinedPrefixIcon = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixIcon != null) prefixIcon!,
          if (prefixText != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 12),
              child: Text(
                prefixText!,
                style: AppTextStyles.bodyMediumRegular.copyWith(
                  color: textColor ?? AppColors.primaryText,
                ),
              ),
            )
          else if (prefixIcon != null)
            const SizedBox(width: 12),
        ],
      );
    }

    final inputDecoration = InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodyMediumRegular.copyWith(
        color: hintColor ?? AppColors.secondaryText,
      ),
      prefixIcon: combinedPrefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: backgroundColor ?? AppColors.inputBackground,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: borderColor ?? AppColors.inputBorder,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: borderColor ?? AppColors.primaryButton,
          width: 1,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: borderColor ?? AppColors.inputBorder,
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.alertText, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.alertText, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      counterText: '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          BaseText.bodySmallRegular(
            text: label!,
            textColor: AppColors.secondaryText,
          ),
          const SizedBox(height: 8),
        ],
        validator != null
            ? TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                enabled: enabled,
                validator: validator,
                onChanged: onChanged,
                focusNode: focusNode,
                maxLength: maxLength,
                style: AppTextStyles.bodyMediumRegular.copyWith(
                  color: textColor ?? AppColors.primaryText,
                ),
                decoration: inputDecoration,
                inputFormatters: inputFormatters,
              )
            : TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                enabled: enabled,
                onChanged: onChanged,
                focusNode: focusNode,
                maxLength: maxLength,
                style: AppTextStyles.bodyMediumRegular.copyWith(
                  color: textColor ?? AppColors.primaryText,
                ),
                decoration: inputDecoration,
                inputFormatters: inputFormatters,
              ),
      ],
    );
  }
}
