import 'package:flutter/foundation.dart';
import 'package:core_module/core_module.dart';
import '../core/module_registry/module_registry.dart';
import '../core/feature_flags/feature_flag_service.dart';

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

/// Orchestrates application bootstrap sequence.
///
/// Order:
/// 1. Create registry
/// 2. Register modules
/// 3. Set up feature flags
/// 4. Check version compatibility
/// 5. Set up DI
/// 6. Initialize modules
class AppBootstrap {
  /// Run the full bootstrap sequence.
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

    try {
      // 1. Register modules
      debugPrint('Bootstrap: Registering ${modules.length} module(s)...');
      registry.registerAll(modules);

      // 2. Set up feature flags
      registry.setFeatureFlagService(featureFlagService);
      await featureFlagService.load();
      debugPrint('Bootstrap: Feature flags loaded.');

      // 3. Check version compatibility
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

      // 4. Set up DI for enabled modules
      debugPrint('Bootstrap: Setting up DI...');
      setupCoreInjection();
      for (final module in registry.enabledModules) {
        debugPrint('Bootstrap: Setting up DI for "${module.name}"...');
        module.setupDependencies();
      }

      // 5. Initialize enabled modules
      debugPrint('Bootstrap: Initializing modules...');
      await registry.initializeAll();

      debugPrint('Bootstrap: Complete.');
      return BootstrapResult(
        registry: registry,
        featureFlagService: featureFlagService,
        compatibility: compatibility,
        compatibilityResults: compatResults,
        success: true,
      );
    } catch (e, stack) {
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
}
