# FeatureModule Contract

## 1. Abstract Interface (module_contracts)

```dart
/// Every feature module must implement this contract.
abstract class FeatureModule {
  /// Unique module identifier (e.g. "resident", "finance").
  String get name;

  /// Human-readable display name.
  String get displayName;

  /// Current semantic version.
  ModuleVersion get version;

  /// Module manifest with full metadata.
  ModuleManifest get manifest;

  /// Module lifecycle: one-time initialization.
  /// Called once at app startup after DI is set up.
  Future<void> initialize();

  /// Routes owned by this module.
  /// Returns GoRouter route configurations.
  List<RouteBase> get routes;

  /// Permissions this module requires.
  List<ModulePermission> get permissions;

  /// Dependency injection initialization.
  /// Called during bootstrap before initialize().
  void setupDependencies();
}
```

## 2. Supporting Types

```dart
/// Semantic version for modules and shell.
class ModuleVersion {
  final int major;
  final int minor;
  final int patch;

  const ModuleVersion(this.major, this.minor, this.patch);

  String get asString => '$major.$minor.$patch';

  @override
  bool operator ==(Object other) =>
      other is ModuleVersion &&
      other.major == major &&
      other.minor == minor &&
      other.patch == patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);
}

/// Route descriptor returned by modules.
class ModuleRoute {
  final String path;
  final String name;
  final WidgetBuilder builder;
  final List<ModuleRoute> children;
  final bool requiresAuth;
  final List<String> requiredPermissions;

  const ModuleRoute({
    required this.path,
    required this.name,
    required this.builder,
    this.children = const [],
    this.requiresAuth = true,
    this.requiredPermissions = const [],
  });
}

/// Permission required by a module.
class ModulePermission {
  final String name;
  final String description;

  const ModulePermission({
    required this.name,
    required this.description,
  });
}
```

## 3. Module Route Registration Contract

Every module provides routes as GoRouter-compatible objects.

**Route structure convention:**

```
/resident              → Resident list
/resident/:id          → Resident detail
/resident/create       → Create resident

/finance               → Finance dashboard
/finance/iuran         → Iuran list
/finance/kas           → Kas overview

/complaint             → Complaint list
/complaint/:id         → Complaint detail

/meeting               → Meeting list
/meeting/:id           → Meeting detail

/security              → Security settings
```

Modules own their route paths completely.
Shell only combines them.

## 4. Contract Implementation Template

```dart
class ResidentModule implements FeatureModule {
  @override
  String get name => 'resident';

  @override
  String get displayName => 'Resident Management';

  @override
  ModuleVersion get version => ModuleVersion(1, 0, 0);

  @override
  ModuleManifest get manifest => _manifest;

  late final ModuleManifest _manifest = ModuleManifest(
    name: name,
    version: version,
    displayName: displayName,
    description: 'Manage resident profiles and data',
    minShellVersion: ModuleVersion(1, 0, 0),
    permissions: [
      ModulePermission(
        name: 'resident.read',
        description: 'Read resident data',
      ),
      ModulePermission(
        name: 'resident.write',
        description: 'Create and update residents',
      ),
    ],
    dependencies: [],
    featureFlags: {
      'resident.enabled': true,
      'resident.export': false,
    },
  );

  @override
  Future<void> initialize() async {
    // Any async setup (DB migrations, API init, etc.)
  }

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: '/resident',
      name: 'resident.list',
      builder: (context, state) => const ResidentListPage(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'resident.detail',
          builder: (context, state) => ResidentDetailPage(
            id: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: 'create',
          name: 'resident.create',
          builder: (context, state) => const ResidentCreatePage(),
        ),
      ],
    ),
  ];

  @override
  List<ModulePermission> get permissions => _manifest.permissions;

  @override
  void setupDependencies() {
    setupResidentInjection();
  }
}
```
