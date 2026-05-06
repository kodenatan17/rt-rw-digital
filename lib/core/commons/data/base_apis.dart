class BaseApis {
  //// Auth Section Apis
  static const String authRequestOtp = "/v1/request-otp";

  static const String authSubmitOtp = "/v1/submit-otp";

  static const String authRefreshToken = "/v1/refresh-token";

  static const String authCompleteUsername = "/v1/username";

  static const String authLogout = "/v1/logout";
  //// User Section Apis
  static const String userDeleteAccount = "/v1/delete-account";

  static const String userLogout = "/v1/logout";

  static const String userProfile = "/v1/profile";

  static const String userHistoryCall = "/v1/history-call";

  //// Call Section Apis
  static const String callHistory = "/v1/history-call";

  static const String call = "/v1/call";

  //// Notification
  static const String notificationStoreToken = "/v1/firebase-token";
  
}