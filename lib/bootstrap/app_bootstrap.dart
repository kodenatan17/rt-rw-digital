import 'package:flutter/foundation.dart';
import 'package:core_module/core_module.dart';
import '../core/module_registry/module_registry.dart';
import '../core/feature_flags/feature_flag_service.dart';
import '../injection/shell_injection.dart';

/// Result of the bootstrap process.
class BootstrapResult {
  final ModuleRegistry registry;
  final FeatureFlagService featureFlagService;
  final VersionCompatibility compatibility;
  final List<CompatibilityResult> compatibilityResults;
  final bool success;
  final String? error;

  const BootstrapResult({
    required this.registry,
    required this.featureFlagService,
    required this.compatibility,
    required this.compatibilityResults,
    required this.success,
    this.error,
  });
}

/// Orchestrates application bootstrap with **Offline-First** strategy.
///
/// # Bootstrap Flow
/// ```
/// App Start
///   ↓
/// Register All Modules
///   ↓
/// Load Cached Feature Flags (non-blocking)
///   ↓
/// DI Setup (all enabled modules)
///   ↓
/// Init Eager Enabled Modules
///   ↓
/// App Ready ✅
///   ↓ (background)
/// Refresh GrowthBook Remote Flags
///   ↓
/// Persist New Flags → Apply Next Session
/// ```
///
/// # Key Properties
/// - **GrowthBook NEVER blocks startup.**
/// - Cache is loaded before first frame.
/// - Remote refresh happens in background after app is ready.
/// - Manifest defaults used when both cache and remote are unavailable.
///
/// # Metrics
/// Call [BootstrapMetrics.printReport] after warmup completes.
class AppBootstrap {
  /// Run the full bootstrap sequence (non-blocking for remote flags).
  static Future<BootstrapResult> run({
    required List<FeatureModule> modules,
    required ModuleVersion shellVersion,
    FeatureFlagRemoteSource? remoteFlagSource,
    FeatureFlagLocalCache? localFlagCache,
    bool skipCompatibilityCheck = false,
    ModuleRegistry? existingRegistry,
    FeatureFlagService? existingFlagService,
  }) async {
    final registry = existingRegistry ?? ModuleRegistry();
    final featureFlagService = existingFlagService ??
        FeatureFlagService(
          remoteSource: remoteFlagSource,
          localCache: localFlagCache,
        );

    registry.metrics.totalWatch.start();

    try {
      // ═══════════════════════════════════════════════
      //  PHASE 1: Register All Modules (lightweight)
      // ═══════════════════════════════════════════════
      debugPrint('Bootstrap: Registering ${modules.length} module(s)...');
      registry.registerAll(modules);

      // ═══════════════════════════════════════════════
      //  PHASE 2: Version Compatibility Check
      // ═══════════════════════════════════════════════
      final compatibility = VersionCompatibility(shellVersion: shellVersion);
      registry.setCompatibility(compatibility);
      final compatResults = registry.checkCompatibility();

      if (!skipCompatibilityCheck) {
        final blocking = compatResults
            .where((r) => r.severity == CompatibilitySeverity.blocking)
            .toList();
        if (blocking.isNotEmpty) {
          final messages = blocking.map((r) => r.reason!).join('; ');
          debugPrint('Bootstrap: Blocking compatibility issues: $messages');
          registry.metrics.totalWatch.stop();
          return BootstrapResult(
            registry: registry,
            featureFlagService: featureFlagService,
            compatibility: compatibility,
            compatibilityResults: compatResults,
            success: false,
            error: 'Compatibility check failed: $messages',
          );
        }
      }

      // ═══════════════════════════════════════════════
      //  PHASE 3: Load Cached Feature Flags (non-blocking)
      // ═══════════════════════════════════════════════
      registry.setFeatureFlagService(featureFlagService);
      await featureFlagService.loadCached();
      debugPrint('Bootstrap: Feature flags loaded from cache.');

      // ═══════════════════════════════════════════════
      //  PHASE 4: DI Setup (all enabled modules)
      // ═══════════════════════════════════════════════
      debugPrint('Bootstrap: Setting up DI...');
      registry.metrics.diWatch.start();

      // Shell DI is idempotent (isRegistered guards inside).
      setupShellInjection();

      // Core DI — external package (injectable). Double-registration
      // would throw StateError only if injectable.initCore is called
      // twice. Wrapping defensively to prevent a re-entrant
      // AppBootstrap.run from failing the whole bootstrap.
      _trySetupCoreInjection();

      for (final module in registry.enabledModules) {
        debugPrint('Bootstrap: Setting up DI for "${module.name}"...');
        module.setupDependencies();
      }
      registry.metrics.diWatch.stop();

      // ═══════════════════════════════════════════════
      //  PHASE 5: Init Eager Modules (blocking)
      // ═══════════════════════════════════════════════
      final eagerCount = registry.eagerModules.length;
      debugPrint('Bootstrap: Initializing $eagerCount eager module(s)...');
      registry.metrics.initWatch.start();
      await registry.initializeByStrategy(ModuleInitializationStrategy.eager);
      registry.metrics.initWatch.stop();

      registry.metrics.totalWatch.stop();

      debugPrint('Bootstrap: Complete.');
      debugPrint(
        '  Registered: ${registry.count} module(s), '
        'Initialized: ${registry.metrics.initializedCount} module(s), '
        'Startup: ${registry.metrics.totalWatch.elapsed.inMilliseconds} ms',
      );

      return BootstrapResult(
        registry: registry,
        featureFlagService: featureFlagService,
        compatibility: compatibility,
        compatibilityResults: compatResults,
        success: true,
      );
    } catch (e, stack) {
      registry.metrics.totalWatch.stop();
      debugPrint('Bootstrap: Failed: $e');
      debugPrint('$stack');
      return BootstrapResult(
        registry: registry,
        featureFlagService: featureFlagService,
        compatibility: VersionCompatibility(shellVersion: shellVersion),
        compatibilityResults: [],
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Calls [setupCoreInjection] without letting a double-registration
  /// error propagate to the outer [BootstrapResult] failure path.
  static void _trySetupCoreInjection() {
    try {
      setupCoreInjection();
    } catch (e) {
      // injectable.initCore throws StateError when called twice.
      // This is safe to skip — types are already registered.
      debugPrint('Bootstrap: setupCoreInjection skipped (already ran): $e');
    }
  }
}

/// Extension on [ModuleRegistry] for post-bootstrap operations.
///
/// Usage:
/// ```dart
/// // After first frame:
/// WidgetsBinding.instance.addPostFrameCallback((_) async {
///   await registry.scheduleWarmup();
///   await registry.scheduleBackgroundRefresh();
///   registry.metrics.printReport();
/// });
/// ```
extension PostBootstrapExtension on ModuleRegistry {
  /// Initialize warmup modules in background (non-blocking).
  Future<void> scheduleWarmup() async {
    final warmup = warmupModules;
    if (warmup.isEmpty) return;
    debugPrint('ModuleRegistry: Warmup ${warmup.length} module(s)...');
    for (final module in warmup) {
      await initializeModule(module.name);
    }
    debugPrint('ModuleRegistry: Warmup complete.');
  }

  /// Refresh feature flags from remote in background.
  ///
  /// Safe to call at any time. Persists flags for next cold start.
  Future<void> scheduleBackgroundRefresh() async {
    final ffService = featureFlagService;
    if (ffService == null) return;
    debugPrint('ModuleRegistry: Background flag refresh...');
    final updated = await ffService.refreshRemote();
    if (updated) {
      debugPrint('ModuleRegistry: Flags refreshed, applying to module states.');
    }
  }
}
