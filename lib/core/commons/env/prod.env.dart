part of 'env.dart';

@Envied(path: '.prod.env', obfuscate: true)
abstract class BaseProdEnv {
  @EnviedField(varName: 'BASE_URL')
  static String baseUrl = _BaseProdEnv.baseUrl;

  @EnviedField(varName: 'USER_URL')
  static String userUrl = _BaseProdEnv.userUrl;

  @EnviedField(varName: 'FIREBASE_API_KEY')
  static String firebaseApiKey = _BaseProdEnv.firebaseApiKey;

  @EnviedField(varName: 'FIREBASE_APP_ID')
  static String firebaseAppId = _BaseProdEnv.firebaseAppId;

  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID')
  static String firebaseMessagingSenderId =
      _BaseProdEnv.firebaseMessagingSenderId;

  @EnviedField(varName: 'FIREBASE_PROJECT_ID')
  static String firebaseProjectId = _BaseProdEnv.firebaseProjectId;

  @EnviedField(varName: 'FIREBASE_STORAGE_BUCKET')
  static String firebaseStorageBucket = _BaseProdEnv.firebaseStorageBucket;

  @EnviedField(varName: 'FIREBASE_API_KEY_IOS')
  static String firebaseApiKeyIos = _BaseProdEnv.firebaseApiKeyIos;

  @EnviedField(varName: 'FIREBASE_ANDROID_CLIENT_ID')
  static String firebaseAndroidClientId = _BaseProdEnv.firebaseAndroidClientId;

  @EnviedField(varName: 'FIREBASE_IOS_BUNDLE_ID')
  static String firebaseIosBundleId = _BaseProdEnv.firebaseIosBundleId;

  @EnviedField(varName: 'FIREBASE_APP_DISTRIBUTION_URL')
  static String firebaseAppDistributionUrl =
      _BaseProdEnv.firebaseAppDistributionUrl;

  @EnviedField(varName: 'APP_ID_AGORA')
  static String appIdAgora = _BaseProdEnv.appIdAgora;
}
