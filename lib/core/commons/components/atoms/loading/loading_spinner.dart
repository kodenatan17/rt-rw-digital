import 'package:flutter/material.dart';
import 'package:pasconnect/core/commons/components/atoms/colors/colors.dart';

class LoadingSpinner extends StatelessWidget {
  final double size;

  const LoadingSpinner({super.key, this.size = 120.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppColors.primaryBackground,
              shape: BoxShape.circle,
            ),
          ),
          CircularProgressIndicator(
            color: AppColors.primaryText,
            strokeAlign: 4,
            strokeWidth: 6,
          ),
        ],
      ),
    );
  }
}