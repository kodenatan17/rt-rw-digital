# ModuleRegistry Design

## 1. Purpose

Central registry that manages all feature modules in the application.

Responsibilities:
- Register modules at bootstrap
- Discover registered modules
- Enable/disable modules based on feature flags
- Expose module metadata
- Provide filtered module lists for UI
- Handle version compatibility checks

## 2. Interface

```dart
class ModuleRegistry {
  final Map<String, FeatureModule> _modules = {};
  final Map<String, bool> _enabledOverrides = {};
  FeatureFlagService? _featureFlagService;
  VersionCompatibility? _compatibility;

  // ── Registration ──────────────────────────────────

  /// Register a single module.
  void register(FeatureModule module);

  /// Register multiple modules at once.
  void registerAll(List<FeatureModule> modules);

  // ── Discovery ─────────────────────────────────────

  /// All registered modules.
  List<FeatureModule> get allModules;

  /// Only modules that are enabled (after feature flag check).
  List<FeatureModule> get enabledModules;

  /// Get a specific module by name.
  FeatureModule? getModule(String name);

  /// Check if a module is registered.
  bool isRegistered(String name);

  // ── Enable/Disable ────────────────────────────────

  /// Manually enable a module.
  void enable(String name);

  /// Manually disable a module.
  void disable(String name);

  /// Whether a module is enabled (respects feature flags).
  bool isEnabled(String name);

  /// Whether a module's menu should be visible.
  bool isVisible(String name);

  // ── Metadata ──────────────────────────────────────

  /// Get manifest for a module.
  ModuleManifest? getManifest(String name);

  /// Get all manifests.
  List<ModuleManifest> get allManifests;

  /// Get routes from all enabled modules.
  List<RouteBase> get allRoutes;

  // ── Lifecycle ─────────────────────────────────────

  /// Initialize all registered modules.
  Future<void> initializeAll();

  /// Initialize a specific module.
  Future<void> initializeModule(String name);

  // ── Feature Flag Integration ──────────────────────

  /// Set the feature flag service to use for flag evaluation.
  void setFeatureFlagService(FeatureFlagService service);

  /// Refresh module states from feature flags.
  Future<void> refreshFromFeatureFlags();
}
```

## 3. Bootstrap Integration

```dart
// main.dart - New pattern
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Create registry
  final registry = ModuleRegistry();

  // 2. Register modules (modules listed here, not routes)
  registry.registerAll([
    ResidentModule(),
    // Future: FinanceModule(), ComplaintModule(), etc.
  ]);

  // 3. Set up feature flags
  final flagService = FeatureFlagService(
    remoteSource: ApiFeatureFlagSource(),
    localCache: LocalFeatureFlagCache(),
  );
  registry.setFeatureFlagService(flagService);

  // 4. Load feature flags
  await flagService.load();

  // 5. Set up DI
  setupCoreInjection();
  for (final module in registry.enabledModules) {
    module.setupDependencies();
  }

  // 6. Initialize modules
  await registry.initializeAll();

  // 7. Run app
  runApp(MyApp(registry: registry));
}
```

## 4. Registry Usage in Shell

```dart
class MyApp extends StatelessWidget {
  final ModuleRegistry registry;

  const MyApp({super.key, required this.registry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RT-RW Digital',
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          // Shell route with navigation
          ShellRoute(
            builder: (context, state, child) => AppShell(
              registry: registry,
              child: child,
            ),
            routes: [
              // Home/dashboard route
              GoRoute(
                path: '/',
                builder: (context, state) => DashboardPage(
                  registry: registry,
                ),
              ),
              // Module routes - all registered routes auto-included
              ...registry.allRoutes,
            ],
          ),
        ],
      ),
    );
  }
}
```

## 5. Dashboard Integration

```dart
class DashboardPage extends StatelessWidget {
  final ModuleRegistry registry;

  const DashboardPage({super.key, required this.registry});

  @override
  Widget build(BuildContext context) {
    final modules = registry.enabledModules
        .where((m) => registry.isVisible(m.name))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('RT-RW Digital')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return ModuleCard(
            module: module,
            onTap: () => _navigateToModule(context, module),
          );
        },
      ),
    );
  }
}
```

## 6. Sidebar/Navigation Drawer

```dart
class AppNavigationDrawer extends StatelessWidget {
  final ModuleRegistry registry;

  const AppNavigationDrawer({super.key, required this.registry});

  @override
  Widget build(BuildContext context) {
    final menuItems = registry.enabledModules
        .where((m) => registry.isVisible(m.name))
        .map((module) => ListTile(
              title: Text(module.displayName),
              onTap: () => _navigateToModule(context, module),
            ));

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text('RT-RW Digital')),
          ...menuItems,
        ],
      ),
    );
  }
}
```

## 7. Thread Safety

ModuleRegistry runs all operations on the main isolate.
No concurrent access concerns in Flutter's single-threaded UI model.
All async operations are sequential (initialization, flag refresh).
