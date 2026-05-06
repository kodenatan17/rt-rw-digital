import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:envied/envied.dart';

part 'dev.env.dart';
part 'prod.env.dart';

part 'env.g.dart';

enum BaseEnvType { prod, dev }

class BaseEnvirontment {
  late final String _baseUrl;
  late final String _userUrl;
  late final String _firebaseApiKey;
  late final String _firebaseAppId;
  late final String _firebaseMessagingSenderId;
  late final String _firebaseProjectId;
  late final String _firebaseStorageBucket;
  late final String _firebaseApiKeyIos;
  late final String _firebaseAndroidClientId;
  late final String _firebaseIosBundleId;
  late final String _firebaseAppDistributionUrl;
  late final String _appIdAgora;
  bool isBaseInitialized = false;
  bool isFirebaseInitialized = false;
  BaseEnvType? _cachedEnvType;

  static final BaseEnvirontment _singleton = BaseEnvirontment._internal();

  factory BaseEnvirontment() => _singleton;

  BaseEnvirontment._internal();

  /// Get current environment with retry mechanism for platform channel
  Future<BaseEnvType> getCurrentEnv() async {
    if (_cachedEnvType != null) {
      return _cachedEnvType!;
    }

    PackageInfo? packageInfo;

    // Retry mechanism untuk handle "Unable to establish connection on channel" error
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        packageInfo = await PackageInfo.fromPlatform();
        break; // Success, keluar dari loop
      } on PlatformException catch (e) {
        debugPrint('PackageInfo attempt ${attempt + 1} failed: $e');
        if (attempt < 2) {
          // Wait sebelum retry, platform channel mungkin belum siap
          await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
        }
      } catch (e) {
        debugPrint('PackageInfo unexpected error: $e');
        break;
      }
    }

    // Jika packageInfo masih null setelah retry, gunakan default
    if (packageInfo == null) {
      debugPrint('PackageInfo failed after retries, using default env (prod)');
      _cachedEnvType = BaseEnvType.prod;
      return _cachedEnvType!;
    }

    switch (packageInfo.packageName) {
      case "arjaya.telindo.pasconnect.inbound" ||
          "arjaya.telindo.pasconnect.inbound.ios":
        _cachedEnvType = BaseEnvType.prod;
        break;
      case "arjaya.telindo.pasconnect.inbound.staging" ||
          "arjaya.telindo.pasconnect.inbound.ios.staging":
        _cachedEnvType = BaseEnvType.dev;
        break;
      default:
        _cachedEnvType = BaseEnvType.prod;
        break;
    }
    return _cachedEnvType!;
  }

  Future<void> initEnv() async {
    if (!isBaseInitialized) {
      await _getBasedUrlOnEnv();
      isBaseInitialized = true;
      // Also mark Firebase as initialized since _getBasedUrlOnEnv sets all Firebase values
      isFirebaseInitialized = true;
    }
  }

  Future<void> initFirebaseEnv() async {
    // If already initialized by initEnv, skip
    if (isFirebaseInitialized) {
      return;
    }

    // Otherwise initialize Firebase values separately
    Future.wait([
      _getFirebaseApiKey(),
      _getFirebaseAppId(),
      _getFirebaseMessagingSenderId(),
      _getFirebaseProjectId(),
      _getFirebaseStorageBucket(),
      _getFirebaseApiKeyIos(),
      _getFirebaseAndroidClientId(),
      _getFirebaseIosBundleId(),
      _getFirebaseAppDistributionUrl(),
      _getAppIdAgora(),
    ]);
    isFirebaseInitialized = true;
  }

  Future<void> _getAppIdAgora() async {
    final currentEnv = await getCurrentEnv();
    switch (currentEnv) {
      case BaseEnvType.prod:
        _appIdAgora = BaseProdEnv.appIdAgora;
        break;
      case BaseEnvType.dev:
        _appIdAgora = BaseDevEnv.appIdAgora;
        break;
    }
  }

  Future<void> _getBasedUrlOnEnv() async {
    final currentEnv = await getCurrentEnv();
    switch (currentEnv) {
      case BaseEnvType.prod:
        _baseUrl = BaseProdEnv.baseUrl;
        _userUrl = BaseProdEnv.userUrl;
        _firebaseApiKey = BaseProdEnv.firebaseApiKey;
        _firebaseAppId = BaseProdEnv.firebaseAppId;
        _firebaseMessagingSenderId = BaseProdEnv.firebaseMessagingSenderId;
        _firebaseProjectId = BaseProdEnv.firebaseProjectId;
        _firebaseStorageBucket = BaseProdEnv.firebaseStorageBucket;
        _firebaseApiKeyIos = BaseProdEnv.firebaseApiKeyIos;
        _firebaseAndroidClientId = BaseProdEnv.firebaseAndroidClientId;
        _firebaseIosBundleId = BaseProdEnv.firebaseIosBundleId;
        _firebaseAppDistributionUrl = BaseProdEnv.firebaseAppDistributionUrl;
        break;
      case BaseEnvType.dev:
        _baseUrl = BaseDevEnv.baseUrl;
        _userUrl = BaseDevEnv.userUrl;
        _firebaseApiKey = BaseDevEnv.firebaseApiKey;
        _firebaseAppId = BaseDevEnv.firebaseAppId;
        _firebaseMessagingSenderId = BaseDevEnv.firebaseMessagingSenderId;
        _firebaseProjectId = BaseDevEnv.firebaseProjectId;
        _firebaseStorageBucket = BaseDevEnv.firebaseStorageBucket;
        _firebaseApiKeyIos = BaseDevEnv.firebaseApiKeyIos;
        _firebaseAndroidClientId = BaseDevEnv.firebaseAndroidClientId;
        _firebaseIosBundleId = BaseDevEnv.firebaseIosBundleId;
        _firebaseAppDistributionUrl = BaseDevEnv.firebaseAppDistributionUrl;
        break;
    }
  }

  Future<void> _getFirebaseApiKey() async {
    final currentEnv = await getCurrentEnv();
    switch (currentEnv) {
      case BaseEnvType.prod:
        _firebaseApiKey = BaseProdEnv.firebaseApiKey;
        break;
      case BaseEnvType.dev:
        _firebaseApiKey = BaseDevEnv.firebaseApiKey;
        break;
    }
  }

  Future<void> _getFirebaseAppId() async {
    final currentEnv = await getCurrentEnv();
    switch (currentEnv) {
      case BaseEnvType.prod:
        _firebaseAppId = BaseProdEnv.firebaseAppId;
        break;
      case BaseEnvType.dev:
        _firebaseAppId = BaseDevEnv.firebaseAppId;
        break;
    }
  }

  Future<void> _getFirebaseMessagingSenderId() async {
    final currentEnv = await getCurrentEnv();
    switch (currentEnv) {
      case BaseEnvType.prod:
        _firebaseMessagingSenderId = BaseProdEnv.firebaseMessagingSenderId;
        break;
      case BaseEnvType.dev:
        _firebaseMessagingSenderId = BaseDevEnv.firebaseMessagingSenderId;
        break;
    }
  }

  Future<void> _getFirebaseProjectId() async {
    final currentEnv = await getCurrentEnv();
    switch (currentEnv) {
      case BaseEnvType.prod:
        _firebaseProjectId = BaseProdEnv.firebaseProjectId;
        break;
      case BaseEnvType.dev:
        _firebaseProjectId = BaseDevEnv.firebaseProjectId;
        break;
    }
  }

  Future<void> _getFirebaseStorageBucket() async {
    final currentEnv = await getCurrentEnv();
    switch (currentEnv) {
      case BaseEnvType.prod:
        _firebaseStorageBucket = BaseProdEnv.firebaseStorageBucket;
        break;
      case BaseEnvType.dev:
        _firebaseStorageBucket = BaseDevEnv.firebaseStorageBucket;
        break;
    }
  }

  Future<void> _getFirebaseApiKeyIos() async {
    final currentEnv = await getCurrentEnv();
    switch (currentEnv) {
      case BaseEnvType.prod:
        _firebaseApiKeyIos = BaseProdEnv.firebaseApiKeyIos;
        break;
      case BaseEnvType.dev:
        _firebaseApiKeyIos = BaseDevEnv.firebaseApiKeyIos;
        break;
    }
  }

  Future<void> _getFirebaseAndroidClientId() async {
    final currentEnv = await getCurrentEnv();
    switch (currentEnv) {
      case BaseEnvType.prod:
        _firebaseAndroidClientId = BaseProdEnv.firebaseAndroidClientId;
        break;
      case BaseEnvType.dev:
        _firebaseAndroidClientId = BaseDevEnv.firebaseAndroidClientId;
        break;
    }
  }

  Future<void> _getFirebaseIosBundleId() async {
    final currentEnv = await getCurrentEnv();
    switch (currentEnv) {
      case BaseEnvType.prod:
        _firebaseIosBundleId = BaseProdEnv.firebaseIosBundleId;
        break;
      case BaseEnvType.dev:
        _firebaseIosBundleId = BaseDevEnv.firebaseIosBundleId;
        break;
    }
  }

  Future<void> _getFirebaseAppDistributionUrl() async {
    final currentEnv = await getCurrentEnv();
    switch (currentEnv) {
      case BaseEnvType.prod:
        _firebaseAppDistributionUrl = BaseProdEnv.firebaseAppDistributionUrl;
        break;
      case BaseEnvType.dev:
        _firebaseAppDistributionUrl = BaseDevEnv.firebaseAppDistributionUrl;
        break;
    }
  }

  static const int receiveTimeout = 20;

  static const int connectionTimeout = 20;

  String get baseUrl => _baseUrl;

  String get userUrl => _userUrl;

  String get firebaseApiKey => _firebaseApiKey;
  String get firebaseAppId => _firebaseAppId;
  String get firebaseMessagingSenderId => _firebaseMessagingSenderId;
  String get firebaseProjectId => _firebaseProjectId;
  String get firebaseStorageBucket => _firebaseStorageBucket;
  String get firebaseApiKeyIos => _firebaseApiKeyIos;
  String get firebaseAndroidClientId => _firebaseAndroidClientId;
  String get firebaseIosBundleId => _firebaseIosBundleId;
  String get firebaseAppDistributionUrl => _firebaseAppDistributionUrl;
  String get appIdAgora => _appIdAgora;
}
