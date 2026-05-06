import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pasconnect/core/commons/extensions/on_string_extensions.dart';
import 'package:pasconnect/features/user/domain/data/user_profile_data.dart';

part 'user_session_state.dart';

@singleton
class UserSessionCubit extends Cubit<UserSessionState> {
  UserSessionCubit() : super(const UserSessionState());

  bool get isUserLoggedIn => state.accessToken.isNotEmptyOrNull && state.refreshToken.isNotEmptyOrNull;

  String get accessToken => state.accessToken ?? "";

  String get userFcmToken => state.currentFcmToken ?? "";

  void updateUserSession({
    UserProfileData? userData,
    String? accessToken,
    String? refreshToken,
    String? currentFcmToken,
    int? agoraId,
  }) {
    emit(
      state.copyWith(
        userData: userData,
        accessToken: accessToken,
        refreshToken: refreshToken,
        currentFcmToken: currentFcmToken,
        agoraId: agoraId,
      ),
    );
  }

  void clearUserSession() {
    emit(const UserSessionState(
        currentFcmToken: null,
        refreshToken: null,
        accessToken: null,
        userData: null,
        agoraId: null,
    ));
  }
}