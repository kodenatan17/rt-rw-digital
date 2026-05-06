import 'package:equatable/equatable.dart';

abstract class NotificationUnregisterDeviceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationUnregisterDeviceInitial extends NotificationUnregisterDeviceState {
  final bool isLoading;

  NotificationUnregisterDeviceInitial(this.isLoading);

  @override
  List<Object?> get props => [isLoading];
}

class NotificationUnregisterDeviceError extends NotificationUnregisterDeviceState {
  final String message;

  NotificationUnregisterDeviceError(this.message);

  @override
  List<Object?> get props => [message];
}