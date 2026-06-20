import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:core_module/core_module.dart';
import '../feature_flags/feature_flag_service.dart';

/// Central registry managing all feature modules.
///
/// Responsibilities:
/// - Register modules at bootstrap
/// - Discover registered modules
/// - Enable/disable modules based on feature flags
/// - Expose module metadata
/// - Provide filtered module lists for UI
/// - Aggregate module-owned routes
class ModuleRegistry {
  final Map<String, FeatureModule> _modules = {};
  final Map<String, bool> _enabledOverrides = {};
  FeatureFlagService? _featureFlagService;
  VersionCompatibility? _compatibility;
  bool _initialized = false;

  // ── Registration ──────────────────────────────────

  /// Register a single module.
  void register(FeatureModule module) {
    final name = module.name;
    if (_modules.containsKey(name)) {
      debugPrint('ModuleRegistry: Module "$name" already registered. Skipping.');
      return;
    }
    _modules[name] = module;
    debugPrint('ModuleRegistry: Registered module "$name" v${module.version.asString}');
  }

  /// Register multiple modules at once.
  void registerAll(List<FeatureModule> modules) {
    for (final module in modules) {
      register(module);
    }
  }

  // ── Discovery ─────────────────────────────────────

  /// All registered modules.
  List<FeatureModule> get allModules => _modules.values.toList();

  /// Only modules that are currently enabled.
  List<FeatureModule> get enabledModules {
    return _modules.values.where((m) => isEnabled(m.name)).toList();
  }

  /// Get a specific module by name.
  FeatureModule? getModule(String name) => _modules[name];

  /// Check if a module is registered.
  bool isRegistered(String name) => _modules.containsKey(name);

  // ── Enable/Disable ────────────────────────────────

  /// Manually enable a module.
  void enable(String name) {
    _enabledOverrides[name] = true;
  }

  /// Manually disable a module.
  void disable(String name) {
    _enabledOverrides[name] = false;
  }

  /// Whether a module is currently enabled.
  ///
  /// Resolution order:
  /// 1. Manual override (if set)
  /// 2. Feature flag service (if available)
  /// 3. Default from manifest (true if not specified)
  bool isEnabled(String name) {
    final module = _modules[name];
    if (module == null) return false;

    // 1. Manual override
    if (_enabledOverrides.containsKey(name)) {
      return _enabledOverrides[name]!;
    }

    // 2. Feature flag service
    if (_featureFlagService != null) {
      return _featureFlagService!.isModuleEnabled(name);
    }

    // 3. Default
    return module.defaultValueFor('$name.enabled');
  }

  /// Whether a module's menu should be visible.
  bool isVisible(String name) {
    if (!isEnabled(name)) return false;

    if (_featureFlagService != null) {
      return _featureFlagService!.isModuleVisible(name);
    }

    return _modules[name]?.defaultValueFor('$name.visible') ?? true;
  }

  // ── Metadata ──────────────────────────────────────

  /// Get manifest for a module.
  ModuleManifest? getManifest(String name) => _modules[name]?.manifest;

  /// Get all manifests.
  List<ModuleManifest> get allManifests =>
      _modules.values.map((m) => m.manifest).toList();

  /// Get routes from all enabled modules.
  List<RouteBase> get allRoutes {
    final all = <RouteBase>[];
    for (final module in enabledModules) {
      all.addAll(module.routes);
    }
    return all;
  }

  /// Get routes from all registered modules (regardless of enabled state).
  List<RouteBase> get allRoutesRaw {
    final all = <RouteBase>[];
    for (final module in allModules) {
      all.addAll(module.routes);
    }
    return all;
  }

  // ── Lifecycle ─────────────────────────────────────

  /// Initialize all enabled modules.
  Future<void> initializeAll() async {
    if (_initialized) return;

    final enabled = enabledModules;
    for (final module in enabled) {
      await _initializeModule(module);
    }

    _initialized = true;
    debugPrint('ModuleRegistry: Initialized ${enabled.length} module(s)');
  }

  /// Re-initialize a specific module.
  Future<void> reinitializeModule(String name) async {
    final module = _modules[name];
    if (module != null) {
      await _initializeModule(module);
    }
  }

  Future<void> _initializeModule(FeatureModule module) async {
    try {
      debugPrint('ModuleRegistry: Initializing "${module.name}"...');
      await module.initialize();
      debugPrint('ModuleRegistry: "${module.name}" initialized.');
    } catch (e, stack) {
      debugPrint('ModuleRegistry: Failed to initialize "${module.name}": $e');
      debugPrint('$stack');
    }
  }

  // ── Feature Flag Integration ──────────────────────

  /// Set the feature flag service.
  void setFeatureFlagService(FeatureFlagService service) {
    _featureFlagService = service;
  }

  /// Refresh module states from feature flags.
  Future<void> refreshFromFeatureFlags() async {
    if (_featureFlagService == null) return;
    await _featureFlagService!.load();
    debugPrint('ModuleRegistry: Refreshed from feature flags.');
  }

  // ── Version Compatibility ─────────────────────────

  /// Set the version compatibility checker.
  void setCompatibility(VersionCompatibility compatibility) {
    _compatibility = compatibility;
  }

  /// Check all modules for compatibility.
  List<CompatibilityResult> checkCompatibility() {
    final checker = _compatibility;
    if (checker == null) return [];
    return checker.checkAll(allManifests);
  }

  /// Whether all registered modules are compatible.
  bool get isCompatible {
    final checker = _compatibility;
    if (checker == null) return true;
    return checker.areAllCompatible(allManifests);
  }

  // ── Utilities ─────────────────────────────────────

  /// Remove a module from the registry.
  void unregister(String name) {
    _modules.remove(name);
    _enabledOverrides.remove(name);
  }

  /// Number of registered modules.
  int get count => _modules.length;

  /// Whether any modules are registered.
  bool get isEmpty => _modules.isEmpty;

  /// Whether initialization has completed.
  bool get isInitialized => _initialized;
}
