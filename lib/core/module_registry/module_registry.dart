import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:core_module/core_module.dart';
import '../feature_flags/feature_flag_service.dart';

/// Tracks timing for a single module operation.
class ModuleTiming {
  final String moduleName;
  final Stopwatch watch = Stopwatch();

  ModuleTiming(this.moduleName);

  void start() => watch.start();
  void stop() => watch.stop();
  Duration get elapsed => watch.elapsed;
}

/// Aggregated bootstrap metrics.
class BootstrapMetrics {
  final Stopwatch totalWatch = Stopwatch();
  final Stopwatch registrationWatch = Stopwatch();
  final Stopwatch diWatch = Stopwatch();
  final Stopwatch initWatch = Stopwatch();
  final List<ModuleTiming> moduleTimings = [];

  int get registeredCount => moduleTimings.length;
  int _initializedCount = 0;
  int get initializedCount => _initializedCount;

  void markInitialized() => _initializedCount++;

  void printReport() {
    debugPrint('══════════════════════════════════════════════');
    debugPrint('  Bootstrap Report');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('  Total duration:  ${totalWatch.elapsed.inMilliseconds} ms');
    debugPrint('  Registration:    ${registrationWatch.elapsed.inMilliseconds} ms');
    debugPrint('  DI setup:        ${diWatch.elapsed.inMilliseconds} ms');
    debugPrint('  Initialization:  ${initWatch.elapsed.inMilliseconds} ms');
    debugPrint('  Registered:      $registeredCount module(s)');
    debugPrint('  Initialized:     $_initializedCount module(s)');
    debugPrint('──────────────────────────────────────────────');
    for (final t in moduleTimings) {
      debugPrint('  ${t.moduleName.padRight(20)} ${t.elapsed.inMilliseconds} ms');
    }
    debugPrint('══════════════════════════════════════════════');
  }
}

/// Central registry managing all feature modules.
///
/// # Strategy
/// 1. **Register All** — metadata/routes/menus available immediately.
/// 2. **Init Eager** — only [ModuleInitializationStrategy.eager] modules.
/// 3. **Warmup** — [ModuleInitializationStrategy.warmup] after first frame.
/// 4. **Lazy** — [ModuleInitializationStrategy.lazy] on first access.
///
/// # Offline-First
/// - Uses cached flags from [FeatureFlagService] (never blocks).
/// - Manifest defaults used when remote flags unavailable.
///
/// # Lifecycle
/// - [register] / [registerAll] — lightweight, no init.
/// - [initializeModule] — one-time async init (idempotent).
/// - [disposeModule] / [disposeAll] — resource cleanup.
class ModuleRegistry {
  final Map<String, FeatureModule> _modules = {};
  final Map<String, bool> _enabledOverrides = {};
  final Map<String, bool> _initializedModules = {};
  FeatureFlagService? _featureFlagService;
  VersionCompatibility? _compatibility;

  /// Performance metrics for the current session.
  final BootstrapMetrics metrics = BootstrapMetrics();

  // ── Registration ──────────────────────────────────

  /// Register a single module (lightweight — no init).
  void register(FeatureModule module) {
    final name = module.name;
    if (_modules.containsKey(name)) {
      debugPrint('ModuleRegistry: Module "$name" already registered. Skipping.');
      return;
    }
    _modules[name] = module;
    metrics.moduleTimings.add(ModuleTiming(name));
    debugPrint('ModuleRegistry: Registered module "$name" v${module.version.asString}');
  }

  /// Register multiple modules at once.
  void registerAll(List<FeatureModule> modules) {
    metrics.registrationWatch.start();
    for (final module in modules) {
      register(module);
    }
    metrics.registrationWatch.stop();
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

  void enable(String name) => _enabledOverrides[name] = true;
  void disable(String name) => _enabledOverrides[name] = false;

  /// Whether a module is currently enabled.
  ///
  /// Resolution:
  /// 1. Manual override (enable/disable)
  /// 2. Feature flag service (remote → cache)
  /// 3. Module manifest default (defaultEnabled)
  bool isEnabled(String name) {
    final module = _modules[name];
    if (module == null) return false;

    if (_enabledOverrides.containsKey(name)) {
      return _enabledOverrides[name]!;
    }

    if (_featureFlagService != null) {
      return _featureFlagService!.isModuleEnabled(name);
    }

    return module.defaultEnabled;
  }

  /// Whether a module's menu should be visible.
  ///
  /// Resolution:
  /// 1. Must be enabled first.
  /// 2. Feature flag service (remote → cache).
  /// 3. Module manifest default (defaultVisible).
  bool isVisible(String name) {
    if (!isEnabled(name)) return false;

    if (_featureFlagService != null) {
      return _featureFlagService!.isModuleVisible(name);
    }

    return _modules[name]?.defaultVisible ?? true;
  }

  // ── Strategy Filters ──────────────────────────────

  /// Enabled modules with [ModuleInitializationStrategy.eager].
  List<FeatureModule> get eagerModules =>
      enabledModules.where((m) => m.strategy == ModuleInitializationStrategy.eager).toList();

  /// Enabled modules with [ModuleInitializationStrategy.warmup].
  List<FeatureModule> get warmupModules =>
      enabledModules.where((m) => m.strategy == ModuleInitializationStrategy.warmup).toList();

  /// Enabled modules with [ModuleInitializationStrategy.lazy].
  List<FeatureModule> get lazyModules =>
      enabledModules.where((m) => m.strategy == ModuleInitializationStrategy.lazy).toList();

  // ── Lifecycle ─────────────────────────────────────

  /// Initialize a single module (idempotent).
  ///
  /// Returns `true` if initialization actually ran.
  Future<bool> initializeModule(String name) async {
    final module = _modules[name];
    if (module == null) return false;
    if (!isEnabled(name)) return false;
    if (_initializedModules[name] == true) return false;

    final timing = _findTiming(name);
    timing?.start();
    try {
      debugPrint('ModuleRegistry: Initializing "${module.name}"...');
      await module.initialize();
      _initializedModules[name] = true;
      metrics.markInitialized();
      debugPrint('ModuleRegistry: "${module.name}" initialized.');
    } catch (e, stack) {
      debugPrint('ModuleRegistry: Failed to initialize "${module.name}": $e');
      debugPrint('$stack');
    }
    timing?.stop();
    return true;
  }

  /// Initialize all enabled modules of a given strategy.
  Future<void> initializeByStrategy(ModuleInitializationStrategy strategy) async {
    final modules = enabledModules.where((m) => m.strategy == strategy).toList();
    for (final module in modules) {
      await initializeModule(module.name);
    }
  }

  /// Dispose a single module.
  void disposeModule(String name) {
    final module = _modules[name];
    if (module == null) return;
    module.dispose();
    _initializedModules.remove(name);
    debugPrint('ModuleRegistry: Disposed module "$name".');
  }

  /// Dispose all modules.
  void disposeAll() {
    for (final module in allModules) {
      module.dispose();
    }
    _initializedModules.clear();
    debugPrint('ModuleRegistry: Disposed all modules.');
  }

  /// Whether a specific module has been initialized.
  bool isModuleInitialized(String name) => _initializedModules[name] == true;

  // ── DI Setup ──────────────────────────────────────

  void setupModuleDependencies(String name) {
    final module = _modules[name];
    module?.setupDependencies();
  }

  void setupAllDependencies() {
    for (final module in enabledModules) {
      setupModuleDependencies(module.name);
    }
  }

  // ── Metadata ──────────────────────────────────────

  ModuleManifest? getManifest(String name) => _modules[name]?.manifest;

  List<ModuleManifest> get allManifests =>
      _modules.values.map((m) => m.manifest).toList();

  /// Routes from all enabled modules.
  List<RouteBase> get allRoutes {
    final all = <RouteBase>[];
    for (final module in enabledModules) {
      all.addAll(module.routes);
    }
    return all;
  }

  /// Routes from all registered modules (enabled + disabled).
  List<RouteBase> get allRoutesRaw {
    final all = <RouteBase>[];
    for (final module in allModules) {
      all.addAll(module.routes);
    }
    return all;
  }

  // ── Feature Flag Integration ──────────────────────

  /// The current feature flag service instance (nullable).
  FeatureFlagService? get featureFlagService => _featureFlagService;

  void setFeatureFlagService(FeatureFlagService service) {
    _featureFlagService = service;
  }

  Future<void> refreshFromFeatureFlags() async {
    if (_featureFlagService == null) return;
    await _featureFlagService!.loadCached();
    await _featureFlagService!.refreshRemote();
    debugPrint('ModuleRegistry: Refreshed from feature flags.');
  }

  // ── Version Compatibility ─────────────────────────

  void setCompatibility(VersionCompatibility compatibility) {
    _compatibility = compatibility;
  }

  List<CompatibilityResult> checkCompatibility() {
    final checker = _compatibility;
    if (checker == null) return [];
    return checker.checkAll(allManifests);
  }

  bool get isCompatible {
    final checker = _compatibility;
    if (checker == null) return true;
    return checker.areAllCompatible(allManifests);
  }

  // ── Utilities ─────────────────────────────────────

  Future<void> unregister(String name) async {
    disposeModule(name);
    _modules.remove(name);
    _enabledOverrides.remove(name);
  }

  int get count => _modules.length;
  bool get isEmpty => _modules.isEmpty;

  // ── Private ───────────────────────────────────────

  ModuleTiming? _findTiming(String name) {
    try {
      return metrics.moduleTimings.firstWhere((t) => t.moduleName == name);
    } catch (_) {
      return null;
    }
  }
}
