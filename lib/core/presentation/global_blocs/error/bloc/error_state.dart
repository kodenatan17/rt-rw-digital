part of 'error_cubit.dart';

abstract class GlobalErrorState extends Equatable {
  const GlobalErrorState();
}

class ErrorIdle extends GlobalErrorState {
  @override
  List<Object?> get props => [];
}

class ErrorSnackbarState extends GlobalErrorState {
  final String? errorMessage;
  final ErrorTypeEnum errorType;

  const ErrorSnackbarState(this.errorType, this.errorMessage);

  @override
  List<Object?> get props => [errorType];
}