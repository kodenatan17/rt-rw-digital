import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pasconnect/core/presentation/global_blocs/error/error_enum.dart';

part 'error_state.dart';

const _defaultErrorMessage = 'Something Went Wrong';
final List<RegExp> _passthroughErrorMessagePatterns = [
  RegExp(r'^Daily OTP request limit exceeded for 2 requests in the last 24 hours$'),
  RegExp(r'^failed to send OTP, please try again later$'),
  RegExp(r'^invalid or expired token$'),
  RegExp(r'^already maximum attempts, please request a new OTP$'),
  RegExp(r'^invalid OTP code$'),
  RegExp(r'^OTP has expired$'),
  RegExp(r'^Phone number is required$'),
];

@lazySingleton
class GlobalErrorCubit extends Cubit<GlobalErrorState> {
  GlobalErrorCubit() : super(ErrorIdle());

  void showSnackbar({
    required ErrorTypeEnum errorType,
    String? errorMessage,
  }) {
    emit(ErrorSnackbarState(errorType, _resolveErrorMessage(errorMessage)));
  }

  String _resolveErrorMessage(String? errorMessage) {
    if (errorMessage == null) {
      return _defaultErrorMessage;
    }

    final normalizedMessage = errorMessage.trim();
    if (normalizedMessage.isEmpty) {
      return _defaultErrorMessage;
    }

    final isAllowedBackendMessage = _passthroughErrorMessagePatterns.any(
      (pattern) => pattern.hasMatch(normalizedMessage),
    );

    return isAllowedBackendMessage ? normalizedMessage : _defaultErrorMessage;
  }
}