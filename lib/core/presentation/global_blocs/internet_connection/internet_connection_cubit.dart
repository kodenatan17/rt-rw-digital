import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pasconnect/core/presentation/global_blocs/error/error_enum.dart';
import 'package:pasconnect/core/presentation/global_blocs/error/error_stream.dart';

@singleton
class InternetConnectionCubit extends Cubit<bool> {
  InternetConnectionCubit() : super(true);

  StreamSubscription? connectionStatusListener;
  bool _previousConnectionState = true;

  void init() async {
    // Get initial connection state
    final initialResult = await Connectivity().checkConnectivity();
    final initialState = initialResult != ConnectivityResult.none;
    _previousConnectionState = initialState;
    emit(initialState);

    // Listen to connection changes
    connectionStatusListener = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      final bool isConnected =
          !results.contains(ConnectivityResult.none) && results.isNotEmpty;

      if (_previousConnectionState != isConnected) {
        if (isConnected) {
          globalErrorStreamController.add(
            ErrorEvent(ErrorTypeEnum.internetConnected, null),
          );
          emit(true);
        } else {
          globalErrorStreamController.add(
            ErrorEvent(ErrorTypeEnum.noInternet, null),
          );
          emit(false);
        }
        _previousConnectionState = isConnected;
      }
    });
  }

  void reCheckConnectionStatus() async {
    final result = await Connectivity().checkConnectivity();
    final bool isConnected = result != ConnectivityResult.none;
    emit(isConnected);
  }

  void stopStream() => connectionStatusListener?.cancel();
}
