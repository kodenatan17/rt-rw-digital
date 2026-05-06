part of 'user_session_cubit.dart';

class UserSessionState extends Equatable {
  final UserProfileData? userData;
  final String? accessToken;
  final String? refreshToken;
  final String? currentFcmToken;
  final int? agoraId;

  const UserSessionState({
    this.userData,
    this.accessToken,
    this.refreshToken,
    this.currentFcmToken,
    this.agoraId,
  });

  @override
  List<Object?> get props => [
    userData,
    accessToken,
    refreshToken,
    currentFcmToken,
    agoraId,
  ];

  UserSessionState copyWith({
    UserProfileData? userData,
    String? accessToken,
    String? refreshToken,
    String? currentFcmToken,
    int? agoraId,
  }) {
    return UserSessionState(
      userData: userData ?? this.userData,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      currentFcmToken: currentFcmToken ?? this.currentFcmToken,
      agoraId: agoraId ?? this.agoraId,
    );
  }
}
