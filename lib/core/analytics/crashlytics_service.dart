import 'package:core_module/core_module.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

// ══════════════════════════════════════════════════════════════════════
//  Firebase implementation
// ══════════════════════════════════════════════════════════════════════

/// [CrashlyticsService] backed by [FirebaseCrashlytics].
class FirebaseCrashlyticsService implements CrashlyticsService {
  final FirebaseCrashlytics _crashlytics;

  FirebaseCrashlyticsService(this._crashlytics);

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(exception, stack,
          reason: reason, fatal: fatal);
      debugPrint('Crashlytics: error recorded (fatal: $fatal).');
    } catch (e) {
      debugPrint('Crashlytics: failed to record error: $e');
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      debugPrint('Crashlytics: failed to log "$message": $e');
    }
  }

  @override
  Future<void> setUserId(String id) async {
    try {
      await _crashlytics.setUserIdentifier(id);
      debugPrint('Crashlytics: user identifier set to "$id".');
    } catch (e) {
      debugPrint('Crashlytics: failed to set user identifier: $e');
    }
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      debugPrint('Crashlytics: failed to set key "$key": $e');
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
//  No-op implementation
// ══════════════════════════════════════════════════════════════════════

/// Silent [CrashlyticsService] for tests / when Firebase failed to init.
class NoOpCrashlyticsService implements CrashlyticsService {
  const NoOpCrashlyticsService();

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setUserId(String id) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}
}
