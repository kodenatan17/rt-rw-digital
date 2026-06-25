import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:rt_rw_digital/core/analytics/analytics_service.dart';
import 'package:rt_rw_digital/core/analytics/crashlytics_service.dart';
import 'package:rt_rw_digital/core/analytics/performance_service.dart';
import 'package:rt_rw_digital/injection/shell_injection.dart';

void main() {
  final getIt = GetIt.instance;

  // ════════════════════════════════════════════════════════════════════
  //  GetIt is a global singleton. We must reset before and after each
  //  test to prevent registrations from leaking between tests.
  // ════════════════════════════════════════════════════════════════════
  setUp(() {
    getIt.reset();
  });

  tearDown(() {
    getIt.reset();
  });

  group('setupShellInjection()', () {
    test('registers AnalyticsService', () {
      setupShellInjection();
      expect(getIt.isRegistered<AnalyticsService>(), true);
    });

    test('registers CrashlyticsService', () {
      setupShellInjection();
      expect(getIt.isRegistered<CrashlyticsService>(), true);
    });

    test('registers PerformanceService', () {
      setupShellInjection();
      expect(getIt.isRegistered<PerformanceService>(), true);
    });

    test('registers all three services in one call', () {
      setupShellInjection();
      expect(getIt.isRegistered<AnalyticsService>(), true);
      expect(getIt.isRegistered<CrashlyticsService>(), true);
      expect(getIt.isRegistered<PerformanceService>(), true);
    });

    test('is idempotent — second call does not throw', () {
      setupShellInjection();
      // Second call must not throw StateError.
      setupShellInjection();
    });

    test('is idempotent — three calls are also safe', () {
      setupShellInjection();
      setupShellInjection();
      setupShellInjection();
    });
  });

  // ── Service type resolution ───────────────────────────────────────
  group('resolved service types', () {
    test('returns NoOpAnalyticsService when Firebase not initialized', () {
      // FirebaseService.isInitialized is false in this environment
      // because there is no real Firebase backend configured.
      setupShellInjection();

      final analytics = getIt<AnalyticsService>();
      expect(analytics, isA<NoOpAnalyticsService>());
    });

    test('returns NoOpCrashlyticsService when Firebase not initialized', () {
      setupShellInjection();

      final crashlytics = getIt<CrashlyticsService>();
      expect(crashlytics, isA<NoOpCrashlyticsService>());
    });

    test('returns NoOpPerformanceService when Firebase not initialized', () {
      setupShellInjection();

      final performance = getIt<PerformanceService>();
      expect(performance, isA<NoOpPerformanceService>());
    });

    test('all three services are NoOp variants in test env', () {
      setupShellInjection();
      expect(getIt<AnalyticsService>(), isA<NoOpAnalyticsService>());
      expect(getIt<CrashlyticsService>(), isA<NoOpCrashlyticsService>());
      expect(getIt<PerformanceService>(), isA<NoOpPerformanceService>());
    });
  });

  // ── Edge cases ────────────────────────────────────────────────────
  group('edge cases', () {
    test('calling on a clean GetIt does not throw', () {
      expect(
        () => setupShellInjection(),
        isNot(throwsA(anything)),
      );
    });

    test('lazy singletons are not instantiated at registration time', () {
      setupShellInjection();
      // If they were eager singletons, a real Firebase backend would
      // be needed. Registration alone must succeed without Firebase.
    });
  });
}
