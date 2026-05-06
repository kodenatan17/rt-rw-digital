part of 'notification_register_device_cubit.dart';

abstract class NotificationRegisterDeviceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationRegisterDeviceInitial extends NotificationRegisterDeviceState {}

class NotificationRegisterDeviceLoading extends NotificationRegisterDeviceState {}

class NotificationRegisterDeviceSuccess extends NotificationRegisterDeviceState {}

class NotificationRegisterDeviceError extends NotificationRegisterDeviceState {
  final String message;

  NotificationRegisterDeviceError(this.message);

  @override
  List<Object?> get props => [message];
}