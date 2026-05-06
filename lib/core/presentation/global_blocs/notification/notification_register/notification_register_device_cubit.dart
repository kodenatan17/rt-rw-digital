import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pasconnect/features/notification/domain/usecase/notification_store/notification_store_token_params.dart';
import 'package:pasconnect/features/notification/domain/usecase/notification_store/notification_store_token_usecase.dart';

part 'notification_register_device_state.dart';

@injectable
class NotificationRegisterDeviceCubit
    extends Cubit<NotificationRegisterDeviceState> {
  final NotificationStoreTokenUseCase _notificationStoreTokenUseCase;
  final FirebaseMessaging _firebaseMessaging;

  NotificationRegisterDeviceCubit(
    this._notificationStoreTokenUseCase,
    this._firebaseMessaging,
  ) : super(NotificationRegisterDeviceInitial());

  /// Called after successful login to register FCM token
  Future<void> onSuccessLogin() async {
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint('[FCM] Token obtained for registration');
    registerNotificationDevice(fcmToken ?? "");
  }

  /// Register FCM token to backend
  void registerNotificationDevice(String fcmToken) async {
    emit(NotificationRegisterDeviceLoading());
    
    await _notificationStoreTokenUseCase.call(NotificationStoreTokenParams(token: fcmToken)).then((result) {
      result.when(
        success: (data) {
          debugPrint('[FCM] Token registered successfully');
          emit(NotificationRegisterDeviceSuccess());
        },
        error: (error) {
          debugPrint('[FCM] Token registration failed: ${error.message}');
          emit(NotificationRegisterDeviceError(error.message));
        },
      );
    });
  }

  /// Get current FCM token (for debugging in development)
  Future<String?> getFCMToken() async {
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint('[FCM] Current token: $fcmToken');
    return fcmToken;
  }
}
  