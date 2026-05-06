part of 'env.dart';

@Envied(path: '.dev.env', obfuscate: true)
abstract class BaseDevEnv {
  @EnviedField(varName: 'BASE_URL')
  static String baseUrl = _BaseDevEnv.baseUrl;

  @EnviedField(varName: 'USER_URL')
  static String userUrl = _BaseDevEnv.userUrl;

  @EnviedField(varName: 'FIREBASE_API_KEY')
  static String firebaseApiKey = _BaseDevEnv.firebaseApiKey;

  @EnviedField(varName: 'FIREBASE_APP_ID')
  static String firebaseAppId = _BaseDevEnv.firebaseAppId;

  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID')
  static String firebaseMessagingSenderId =
      _BaseDevEnv.firebaseMessagingSenderId;

  @EnviedField(varName: 'FIREBASE_PROJECT_ID')
  static String firebaseProjectId = _BaseDevEnv.firebaseProjectId;

  @EnviedField(varName: 'FIREBASE_STORAGE_BUCKET')
  static String firebaseStorageBucket = _BaseDevEnv.firebaseStorageBucket;

  @EnviedField(varName: 'FIREBASE_API_KEY_IOS')
  static String firebaseApiKeyIos = _BaseDevEnv.firebaseApiKeyIos;

  @EnviedField(varName: 'FIREBASE_ANDROID_CLIENT_ID')
  static String firebaseAndroidClientId = _BaseDevEnv.firebaseAndroidClientId;

  @EnviedField(varName: 'FIREBASE_IOS_BUNDLE_ID')
  static String firebaseIosBundleId = _BaseDevEnv.firebaseIosBundleId;

  @EnviedField(varName: 'FIREBASE_APP_DISTRIBUTION_URL')
  static String firebaseAppDistributionUrl =
      _BaseDevEnv.firebaseAppDistributionUrl;

  @EnviedField(varName: 'APP_ID_AGORA')
  static String appIdAgora = _BaseDevEnv.appIdAgora;
}
