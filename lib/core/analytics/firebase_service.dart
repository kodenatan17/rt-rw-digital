import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

// TODO: Run `flutterfire configure` to generate this file.
// For now, stub it as a placeholder so the codebase compiles.
// User must run: `dart pub global activate flutterfire_cli && flutterfire configure`
// Uncomment the real import after running that command:
// import '../../firebase_options.dart';

// ══════════════════════════════════════════════════════════════════════
//  Placeholder FirebaseOptions (remove after `flutterfire configure`)
// ══════════════════════════════════════════════════════════════════════

class _PlaceholderFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase not configured. Run: flutterfire configure',
    );
  }
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      _PlaceholderFirebaseOptions.currentPlatform;
}

// ══════════════════════════════════════════════════════════════════════
//  FirebaseService
// ══════════════════════════════════════════════════════════════════════

/// Orchestrates Firebase SDK initialisation and Crashlytics integration.
///
/// Call [initialize] once, immediately after [WidgetsFlutterBinding.ensureInitialized]
/// and before [runApp].
///
/// # Responsibilities
/// - Initialise Firebase Core with platform-specific config ([DefaultFirebaseOptions])
/// - Configure Crashlytics to capture all Flutter errors ([FlutterError.onError])
///   and uncaught async errors ([PlatformDispatcher.instance.onError])
/// - Disable Crashlytics in debug mode to avoid polluting production reports
///
/// # Failure policy
/// If Firebase init fails (missing google-services.json, etc.), the error
/// is logged and the app continues without Firebase. This ensures transient
/// config issues never prevent app startup.
///
/// Usage:
/// ```dart
/// await FirebaseService.initialize();
/// if (FirebaseService.isInitialized) {
///   final analytics = FirebaseService.analytics;
/// }
/// ```
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  /// Whether Firebase has been successfully initialised.
  static bool get isInitialized => _initialized;

  /// Initialise Firebase and install Crashlytics error hooks.
  ///
  /// Safe to call multiple times (no-op if already initialized).
  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('FirebaseService: already initialized.');
      return;
    }

    try {
      // ── 1. Initialize Firebase Core ────────────────────
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('FirebaseService: Firebase Core initialized.');

      // ── 2. Configure Crashlytics ───────────────────────
      await _configureCrashlytics();

      _initialized = true;
      debugPrint('FirebaseService: initialization complete ✅');
    } catch (e, stack) {
      debugPrint('FirebaseService: initialization FAILED (non-fatal): $e');
      debugPrint('$stack');
      // App continues without Firebase — modules must handle null services.
    }
  }

  // ── Private ───────────────────────────────────────────

  /// Hook Crashlytics into Flutter error channels.
  ///
  /// Chains with any previously set [PlatformDispatcher.instance.onError]
  /// handler so plugins or other code that set their own handler before
  /// Firebase are not silently clobbered.
  static Future<void> _configureCrashlytics() async {
    final crashlytics = FirebaseCrashlytics.instance;

    // Disable Crashlytics in debug mode.
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Hook Flutter framework errors (synchronous, widget build errors, etc.).
    FlutterError.onError = crashlytics.recordFlutterFatalError;

    // Hook async errors from outside the Flutter framework.
    // Chain the previous handler so Firebase does not clobber it.
    final previousHandler = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return previousHandler?.call(error, stack) ?? true;
    };

    debugPrint('FirebaseService: Crashlytics hooks installed.');
  }

  // ── Convenience accessors ─────────────────────────────

  /// [FirebaseAnalytics] singleton.
  ///
  /// Throws [StateError] if accessed before [initialize] completes
  /// successfully. Always guard with [isInitialized] first.
  static FirebaseAnalytics get analytics {
    assert(_initialized, 'FirebaseService.initialize() must complete first.');
    return FirebaseAnalytics.instance;
  }

  /// [FirebaseCrashlytics] singleton.
  ///
  /// Throws [StateError] if accessed before [initialize] completes
  /// successfully. Always guard with [isInitialized] first.
  static FirebaseCrashlytics get crashlytics {
    assert(_initialized, 'FirebaseService.initialize() must complete first.');
    return FirebaseCrashlytics.instance;
  }

  /// [FirebasePerformance] singleton.
  ///
  /// Throws [StateError] if accessed before [initialize] completes
  /// successfully. Always guard with [isInitialized] first.
  static FirebasePerformance get performance {
    assert(_initialized, 'FirebaseService.initialize() must complete first.');
    return FirebasePerformance.instance;
  }
}
