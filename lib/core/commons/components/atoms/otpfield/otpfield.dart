import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasconnect/core/commons/components/atoms/colors/colors.dart';
import 'package:pasconnect/core/commons/components/atoms/typography/text_styles.dart';

class BaseOTPField extends StatefulWidget {
  final int length;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  final bool autoFocus;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? activeBorderColor;
  final double? width;
  final double? height;

  const BaseOTPField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.autoFocus = true,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.activeBorderColor,
    this.width,
    this.height,
  });

  @override
  State<BaseOTPField> createState() => _BaseOTPFieldState();
}

class _BaseOTPFieldState extends State<BaseOTPField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();

    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes.first.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    }
    _updateCode();
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      _updateCode();
    }
  }

  void _updateCode() {
    final code = _controllers.map((e) => e.text).join();
    widget.onChanged?.call(code);

    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = 8.0;
    final fieldWidth = widget.width ?? 48.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          width: fieldWidth,
          height: widget.height ?? 56,
          margin: EdgeInsets.only(
            right: index < widget.length - 1 ? spacing : 0,
          ),
          child: RawKeyboardListener(
            focusNode: FocusNode(), // khusus listener
            onKey: (event) {
              if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                _onBackspace(index);
              }
            },
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: AppTextStyles.titleLargeRegular.copyWith(
                color: widget.textColor ?? AppColors.primaryText,
              ),
              onChanged: (value) => _onChanged(index, value),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    widget.backgroundColor ?? AppColors.inputBackground,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.borderColor ?? AppColors.inputBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.activeBorderColor ??
                        widget.borderColor ??
                        AppColors.primaryButton,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                counterText: '',
              ),
            ),
          ),
        );
      }),
    );
  }
}
