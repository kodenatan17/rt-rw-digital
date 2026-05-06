import 'package:flutter/material.dart';
import 'package:pasconnect/core/presentation/global_blocs/error/error_enum.dart';

class ErrorSnackbar {
  static void show({
    required BuildContext context,
    required ErrorTypeEnum errorType,
    String? errorMessage,
  }) {
    final snackbarConfig = _getSnackbarConfig(errorType, errorMessage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(snackbarConfig.icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                snackbarConfig.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: snackbarConfig.backgroundColor,
        duration: snackbarConfig.duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }

  static _SnackbarConfig _getSnackbarConfig(
    ErrorTypeEnum errorType,
    String? errorMessage,
  ) {
    switch (errorType) {
      case ErrorTypeEnum.noInternet:
        return _SnackbarConfig(
          message: 'No Internet Connection',
          backgroundColor: const Color(0xFFDC2626), // Red 600
          icon: Icons.wifi_off_rounded,
          duration: const Duration(seconds: 3),
        );
      case ErrorTypeEnum.internetConnected:
        return _SnackbarConfig(
          message: 'Connected',
          backgroundColor: const Color(0xFF16A34A), // Green 600
          icon: Icons.wifi_rounded,
          duration: const Duration(seconds: 2),
        );
      case ErrorTypeEnum.unauthorized:
        return _SnackbarConfig(
          message: errorMessage ?? 'Unauthorized access',
          backgroundColor: const Color(0xFFEA580C), // Orange 600
          icon: Icons.lock_outline_rounded,
          duration: const Duration(seconds: 3),
        );
      case ErrorTypeEnum.forbidden:
        return _SnackbarConfig(
          message: errorMessage ?? 'Access forbidden',
          backgroundColor: const Color(0xFFEA580C), // Orange 600
          icon: Icons.block_rounded,
          duration: const Duration(seconds: 3),
        );
      case ErrorTypeEnum.serverError:
        return _SnackbarConfig(
          message: errorMessage ?? 'Server error occurred',
          backgroundColor: const Color(0xFFDC2626), // Red 600
          icon: Icons.error_outline_rounded,
          duration: const Duration(seconds: 3),
        );
      case ErrorTypeEnum.pageNotFound:
        return _SnackbarConfig(
          message: errorMessage ?? 'Page not found',
          backgroundColor: const Color(0xFF7C3AED), // Purple 600
          icon: Icons.search_off_rounded,
          duration: const Duration(seconds: 3),
        );
      case ErrorTypeEnum.somethingWrong:
        return _SnackbarConfig(
          message: errorMessage ?? 'Something went wrong',
          backgroundColor: const Color(0xFFDC2626), // Red 600
          icon: Icons.warning_amber_rounded,
          duration: const Duration(seconds: 3),
        );
    }
  }
}

class _SnackbarConfig {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final Duration duration;

  _SnackbarConfig({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.duration,
  });
}
