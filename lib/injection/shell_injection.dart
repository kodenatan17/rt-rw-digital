import 'package:core_module/core_module.dart';
import 'package:get_it/get_it.dart';

import '../core/analytics/analytics.dart';

// ══════════════════════════════════════════════════════════════════════
//  Shell DI Registration
// ══════════════════════════════════════════════════════════════════════

/// Register shell-level services into [GetIt].
///
/// Must be called BEFORE [setupCoreInjection] so that core and module
/// code can safely depend on [AnalyticsService], [CrashlyticsService],
/// and [PerformanceService] from the moment DI is ready.
///
/// # Firebase guard
/// If [FirebaseService.initialize] failed, no-op implementations are
/// registered instead. This ensures callers never receive `null` from
/// [GetIt] and never need to null-check a Firebase service.
///
/// # Idempotency
/// Each registration is guarded by [GetIt.isRegistered] so multiple
/// calls are safe. This is essential because [AppBootstrap.run] calls
/// [setupShellInjection] on every invocation, including re-entrant
/// calls that pass [AppBootstrap.run] with [existingRegistry].
void setupShellInjection() {
  final getIt = GetIt.instance;
  final firebaseReady = FirebaseService.isInitialized;

  // ── Analytics ────────────────────────────────────────
  if (!getIt.isRegistered<AnalyticsService>()) {
    getIt.registerLazySingleton<AnalyticsService>(
      () => firebaseReady
          ? FirebaseAnalyticsService(FirebaseService.analytics)
          : const NoOpAnalyticsService(),
    );
  }

  // ── Crashlytics ──────────────────────────────────────
  if (!getIt.isRegistered<CrashlyticsService>()) {
    getIt.registerLazySingleton<CrashlyticsService>(
      () => firebaseReady
          ? FirebaseCrashlyticsService(FirebaseService.crashlytics)
          : const NoOpCrashlyticsService(),
    );
  }

  // ── Performance ──────────────────────────────────────
  if (!getIt.isRegistered<PerformanceService>()) {
    getIt.registerLazySingleton<PerformanceService>(
      () => firebaseReady
          ? FirebasePerformanceService(FirebaseService.performance)
          : const NoOpPerformanceService(),
    );
  }
}
