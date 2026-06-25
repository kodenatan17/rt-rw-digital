import 'package:core_module/core_module.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

// ══════════════════════════════════════════════════════════════════════
//  Firebase implementation
// ══════════════════════════════════════════════════════════════════════

/// [AnalyticsService] backed by [FirebaseAnalytics].
///
/// All calls are individually try/caught so a single bad event name
/// never crashes the caller.
class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsService(this._analytics);

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('Analytics: event "$name" logged.');
    } catch (e) {
      debugPrint('Analytics: failed to log event "$name": $e');
    }
  }

  @override
  Future<void> setUserId(String? id) async {
    try {
      await _analytics.setUserId(id: id);
      debugPrint('Analytics: user ID ${id == null ? 'cleared' : 'set to "$id"'}.');
    } catch (e) {
      debugPrint('Analytics: failed to set user ID: $e');
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      debugPrint('Analytics: user property "$name" = "$value".');
    } catch (e) {
      debugPrint('Analytics: failed to set user property "$name": $e');
    }
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      debugPrint('Analytics: screen view "$screenName" logged.');
    } catch (e) {
      debugPrint('Analytics: failed to log screen view "$screenName": $e');
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
//  No-op implementation (tests / Firebase disabled)
// ══════════════════════════════════════════════════════════════════════

/// Silent [AnalyticsService] used in unit tests or when Firebase
/// failed to initialise.
class NoOpAnalyticsService implements AnalyticsService {
  const NoOpAnalyticsService();

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> setUserId(String? id) async {}

  @override
  Future<void> setUserProperty({required String name, required String? value}) async {}

  @override
  Future<void> logScreenView({required String screenName, String? screenClass}) async {}
}
