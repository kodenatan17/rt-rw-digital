import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rt_rw_digital/core/analytics/analytics_service.dart';

// ══════════════════════════════════════════════════════════════════════
//  Mockito mock — intercepts all FirebaseAnalytics method calls via
//  noSuchMethod. No build_runner needed for this pattern.
// ══════════════════════════════════════════════════════════════════════

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  // ── FirebaseAnalyticsService tests ─────────────────────────────────
  group('FirebaseAnalyticsService', () {
    late MockFirebaseAnalytics mockAnalytics;
    late FirebaseAnalyticsService service;

    setUp(() {
      mockAnalytics = MockFirebaseAnalytics();
      service = FirebaseAnalyticsService(mockAnalytics);
    });

    // logEvent ---------------------------------------------------------
    test('logEvent delegates to FirebaseAnalytics.logEvent with params', () async {
      await service.logEvent('test_event', parameters: {'key': 'value'});

      verify(
        mockAnalytics.logEvent(
          name: 'test_event',
          parameters: {'key': 'value'},
        ),
      ).called(1);
    });

    test('logEvent delegates with null parameters', () async {
      await service.logEvent('test_event');

      verify(mockAnalytics.logEvent(name: 'test_event', parameters: null))
          .called(1);
    });

    test('logEvent does not re-throw Firebase plugin exception', () async {
      when(
        mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        ),
      ).thenThrow(Exception('Plugin channel error'));

      // Must complete without propagating the exception.
      await service.logEvent('test_event');
    });

    test('logEvent does not re-throw AssertionError from bad event names', () async {
      when(
        mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        ),
      ).thenThrow(AssertionError('Event name invalid'));

      await service.logEvent('');
    });

    // setUserId --------------------------------------------------------
    test('setUserId delegates with a valid ID', () async {
      await service.setUserId('user_123');
      verify(mockAnalytics.setUserId(id: 'user_123')).called(1);
    });

    test('setUserId with null clears the user ID', () async {
      await service.setUserId(null);
      verify(mockAnalytics.setUserId(id: null)).called(1);
    });

    test('setUserId does not re-throw plugin exception', () async {
      when(mockAnalytics.setUserId(id: anyNamed('id')))
          .thenThrow(Exception('Plugin error'));
      await service.setUserId('user_123');
    });

    // setUserProperty --------------------------------------------------
    test('setUserProperty delegates with name and value', () async {
      await service.setUserProperty(name: 'role', value: 'admin');
      verify(mockAnalytics.setUserProperty(name: 'role', value: 'admin'))
          .called(1);
    });

    test('setUserProperty with null value clears the property', () async {
      await service.setUserProperty(name: 'role', value: null);
      verify(mockAnalytics.setUserProperty(name: 'role', value: null))
          .called(1);
    });

    test('setUserProperty does not re-throw plugin exception', () async {
      when(
        mockAnalytics.setUserProperty(
          name: anyNamed('name'),
          value: anyNamed('value'),
        ),
      ).thenThrow(Exception('Plugin error'));
      await service.setUserProperty(name: 'role', value: 'admin');
    });

    // logScreenView ----------------------------------------------------
    test('logScreenView delegates with screenName and screenClass', () async {
      await service.logScreenView(
        screenName: 'Dashboard',
        screenClass: 'DashboardPage',
      );
      verify(
        mockAnalytics.logScreenView(
          screenName: 'Dashboard',
          screenClass: 'DashboardPage',
        ),
      ).called(1);
    });

    test('logScreenView accepts null screenClass', () async {
      await service.logScreenView(screenName: 'Login');
      verify(
        mockAnalytics.logScreenView(screenName: 'Login', screenClass: null),
      ).called(1);
    });

    test('logScreenView does not re-throw plugin exception', () async {
      when(
        mockAnalytics.logScreenView(
          screenName: anyNamed('screenName'),
          screenClass: anyNamed('screenClass'),
        ),
      ).thenThrow(Exception('Plugin error'));
      await service.logScreenView(screenName: 'Dashboard');
    });
  });

  // ── NoOpAnalyticsService tests ────────────────────────────────────
  group('NoOpAnalyticsService', () {
    late NoOpAnalyticsService noop;

    setUp(() {
      noop = const NoOpAnalyticsService();
    });

    test('logEvent completes silently', () async {
      await noop.logEvent('any');
    });

    test('setUserId completes silently', () async {
      await noop.setUserId('any');
    });

    test('setUserProperty completes silently', () async {
      await noop.setUserProperty(name: 'any', value: 'val');
    });

    test('logScreenView completes silently', () async {
      await noop.logScreenView(screenName: 'any');
    });

    test('const constructor returns canonical instance', () {
      expect(
        const NoOpAnalyticsService(),
        same(const NoOpAnalyticsService()),
      );
    });
  });
}
