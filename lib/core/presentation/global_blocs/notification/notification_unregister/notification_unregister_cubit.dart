// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// part 'notification_unregister_device_state.dart';

// class NotificationUnregisterDeviceCubit extends Cubit<NotificationUnregisterDeviceState> {

//   final FirebaseMessaging _fcm;
  
//   NotificationUnregisterDeviceCubit(this._fcm) : super(NotificationUnregisterDeviceInitial(false));
  
//   Future<void> unregisterDevice() async {
//     emit(NotificationUnregisterDeviceLoading());
//     final result = await _notificationUnregisterDeviceUseCase.call();
//     result.when(
//       success: (data) => emit(NotificationUnregisterDeviceSuccess()),
//       error: (error) => emit(NotificationUnregisterDeviceError(error.message)),
//     );
//   }
// }