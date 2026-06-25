import 'package:flutter_test/flutter_test.dart';
import 'package:rt_rw_digital/core/analytics/firebase_service.dart';

void main() {
  // ════════════════════════════════════════════════════════════════════
  //  FirebaseService tests
  // ════════════════════════════════════════════════════════════════════
  //
  //  FirebaseService uses a static _initialized flag. In unit tests,
  //  Firebase.initializeApp() cannot succeed because the placeholder
  //  DefaultFirebaseOptions.currentPlatform throws UnsupportedError.
  //
  //  The try/catch inside FirebaseService.initialize() absorbs this
  //  error gracefully, so _initialized always remains false after
  //  calling initialize().
  //
  //  We do NOT need to reset _initialized between tests — it starts
  //  as false and stays false in this environment.
  //
  //  ⚠  DO NOT attempt (FirebaseService as dynamic)._initialized = …
  //     Library-private fields cannot be accessed cross-library even
  //     through dynamic casts. The Dart VM will throw NoSuchMethodError.

  group('FirebaseService', () {
    test('isInitialized is false before initialize()', () {
      expect(FirebaseService.isInitialized, false);
    });

    test('initialize() fails gracefully when Firebase not configured', () async {
      // The stub DefaultFirebaseOptions.currentPlatform throws
      // UnsupportedError, caught by the try/catch in initialize().
      await FirebaseService.initialize();
      expect(FirebaseService.isInitialized, false);
    });

    test('initialize() is safe to call multiple times', () async {
      // Idempotency: first call fails, second call sees _initialized
      // still false (since init never succeeded) and tries again.
      await FirebaseService.initialize();
      await FirebaseService.initialize();
      expect(FirebaseService.isInitialized, false);
    });

    test('analytics accessor throws AssertionError before init', () {
      // Assertions are enabled in flutter test (debug mode), so the
      // assert(_initialized, …) inside the getter fires.
      expect(
        () => FirebaseService.analytics,
        throwsA(isA<AssertionError>()),
      );
    });

    test('crashlytics accessor throws AssertionError before init', () {
      expect(
        () => FirebaseService.crashlytics,
        throwsA(isA<AssertionError>()),
      );
    });

    test('performance accessor throws AssertionError before init', () {
      expect(
        () => FirebaseService.performance,
        throwsA(isA<AssertionError>()),
      );
    });

    test('analytics accessor message is descriptive', () {
      try {
        FirebaseService.analytics;
        fail('Expected AssertionError');
      } on AssertionError catch (e) {
        expect(
          e.message,
          contains('FirebaseService.initialize() must complete first'),
        );
      }
    });
  });
}
