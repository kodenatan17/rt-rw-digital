import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rt_rw_digital/core/analytics/crashlytics_service.dart';

// ══════════════════════════════════════════════════════════════════════
//  Mockito mock
// ══════════════════════════════════════════════════════════════════════

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  // ── FirebaseCrashlyticsService tests ───────────────────────────────
  group('FirebaseCrashlyticsService', () {
    late MockFirebaseCrashlytics mockCrashlytics;
    late FirebaseCrashlyticsService service;

    setUp(() {
      mockCrashlytics = MockFirebaseCrashlytics();
      service = FirebaseCrashlyticsService(mockCrashlytics);
    });

    // recordError ------------------------------------------------------
    test('recordError delegates with all optional params', () async {
      final error = Exception('test crash');
      final stack = StackTrace.current;

      await service.recordError(error, stack, reason: 'test', fatal: true);

      verify(
        mockCrashlytics.recordError(error, stack, reason: 'test', fatal: true),
      ).called(1);
    });

    test('recordError delegates without optional params', () async {
      final error = Exception('test');

      await service.recordError(error, null);

      verify(
        mockCrashlytics.recordError(error, null, reason: null, fatal: false),
      ).called(1);
    });

    test('recordError uses default fatal=false', () async {
      final error = Exception();

      await service.recordError(error, StackTrace.current);

      verify(
        mockCrashlytics.recordError(
          error,
          any,
          reason: null,
          fatal: false,
        ),
      ).called(1);
    });

    test('recordError does not re-throw plugin exception', () async {
      when(mockCrashlytics.recordError(
        any,
        any,
        reason: anyNamed('reason'),
        fatal: anyNamed('fatal'),
      )).thenThrow(Exception('Plugin error'));

      await service.recordError(Exception('x'), StackTrace.current);
    });

    test('recordError with null stack does not crash', () async {
      await service.recordError('string error', null);
      verify(mockCrashlytics.recordError('string error', null,
              reason: null, fatal: false))
          .called(1);
    });

    // log --------------------------------------------------------------
    test('log delegates to FirebaseCrashlytics.log', () async {
      await service.log('breadcrumb');
      verify(mockCrashlytics.log('breadcrumb')).called(1);
    });

    test('log does not re-throw plugin exception', () async {
      when(mockCrashlytics.log(any)).thenThrow(Exception('Plugin error'));
      await service.log('message');
    });

    // setUserId --------------------------------------------------------
    test('setUserId delegates to FirebaseCrashlytics.setUserIdentifier', () async {
      await service.setUserId('user_456');
      verify(mockCrashlytics.setUserIdentifier('user_456')).called(1);
    });

    test('setUserId handles empty string', () async {
      await service.setUserId('');
      verify(mockCrashlytics.setUserIdentifier('')).called(1);
    });

    test('setUserId does not re-throw plugin exception', () async {
      when(mockCrashlytics.setUserIdentifier(any))
          .thenThrow(Exception('Plugin error'));
      await service.setUserId('user_456');
    });

    // setCustomKey -----------------------------------------------------
    test('setCustomKey delegates with string value', () async {
      await service.setCustomKey('key_name', 'string_value');
      verify(mockCrashlytics.setCustomKey('key_name', 'string_value'))
          .called(1);
    });

    test('setCustomKey delegates with integer value', () async {
      await service.setCustomKey('count', 42);
      verify(mockCrashlytics.setCustomKey('count', 42)).called(1);
    });

    test('setCustomKey delegates with boolean value', () async {
      await service.setCustomKey('enabled', true);
      verify(mockCrashlytics.setCustomKey('enabled', true)).called(1);
    });

    test('setCustomKey does not re-throw plugin exception', () async {
      when(mockCrashlytics.setCustomKey(any, any))
          .thenThrow(Exception('Plugin error'));
      await service.setCustomKey('key', 'value');
    });
  });

  // ── NoOpCrashlyticsService tests ──────────────────────────────────
  group('NoOpCrashlyticsService', () {
    late NoOpCrashlyticsService noop;

    setUp(() {
      noop = const NoOpCrashlyticsService();
    });

    test('recordError completes silently', () async {
      await noop.recordError(Exception('x'), StackTrace.current);
    });

    test('log completes silently', () async {
      await noop.log('any');
    });

    test('setUserId completes silently', () async {
      await noop.setUserId('any');
    });

    test('setCustomKey completes silently', () async {
      await noop.setCustomKey('k', 'v');
    });

    test('const constructor returns canonical instance', () {
      expect(
        const NoOpCrashlyticsService(),
        same(const NoOpCrashlyticsService()),
      );
    });
  });
}
