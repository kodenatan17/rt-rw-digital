# Example Implementation - resident_module

## 1. Current State

Current resident_module has:
- Resident entity + ResidentStatus enum
- ResidentRepository interface
- ResidentRepositoryImpl (in-memory)
- ResidentModel (JSON serialization)
- GetIt injection setup
- Empty routes, presentation, infrastructure

## 2. Migration Steps

### Step 1: Add module_contracts dependency

```yaml
# pubspec.yaml
dependencies:
  module_contracts:
    path: ../module_contracts
```

### Step 2: Create Module Definition

```dart
// lib/module/resident_module_definition.dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:module_contracts/module_contracts.dart';

import '../injection/resident_injection.dart';
import '../manifest/manifest.dart';
import '../routes/resident_routes.dart';
import '../presentation/pages/resident_list_page.dart';
import '../presentation/pages/resident_detail_page.dart';
import '../presentation/pages/resident_create_page.dart';

class ResidentModule implements FeatureModule {
  @override
  String get name => 'resident';

  @override
  String get displayName => 'Resident Management';

  @override
  ModuleVersion get version => ModuleVersion(1, 0, 0);

  @override
  ModuleManifest get manifest => moduleManifest;

  @override
  Future<void> initialize() async {
    // Future: Initialize local DB, preload data, etc.
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
  List<ModulePermission> get permissions => moduleManifest.permissions;

  @override
  void setupDependencies() {
    setupResidentInjection();
  }
}
```

### Step 3: Create Manifest

```dart
// lib/manifest/manifest.dart
import 'package:module_contracts/module_contracts.dart';

final moduleManifest = ModuleManifest(
  name: 'resident',
  displayName: 'Resident Management',
  version: ModuleVersion(1, 0, 0),
  description: 'Manage resident profiles, phone numbers, and email addresses',
  minShellVersion: ModuleVersion(1, 0, 0),
  recommendedShellVersion: ModuleVersion(1, 0, 0),
  permissions: [
    ModulePermission(
      name: 'resident.read',
      description: 'View resident profiles and contact information',
    ),
    ModulePermission(
      name: 'resident.write',
      description: 'Create and update resident profiles',
    ),
    ModulePermission(
      name: 'resident.delete',
      description: 'Remove resident profiles',
    ),
  ],
  dependencies: [
    ModuleDependency(
      moduleName: 'core_module',
      minVersion: ModuleVersion(1, 0, 0),
    ),
  ],
  featureFlags: {
    'resident.enabled': true,
    'resident.visible': true,
    'resident.export': false,
  },
  provides: [
    'resident.crud',
    'resident.search',
    'resident.contact',
  ],
  routeDefinitions: [
    RouteDefinition(
      path: '/resident',
      name: 'resident.list',
      description: 'List all residents',
      requiresAuth: true,
    ),
    RouteDefinition(
      path: '/resident/:id',
      name: 'resident.detail',
      description: 'View resident details',
      requiresAuth: true,
    ),
    RouteDefinition(
      path: '/resident/create',
      name: 'resident.create',
      description: 'Register new resident',
      requiresAuth: true,
      requiredPermissions: ['resident.write'],
    ),
  ],
);
```

### Step 4: Update Routes

```dart
// lib/routes/resident_routes.dart
import 'package:go_router/go_router.dart';
import '../presentation/pages/resident_list_page.dart';
import '../presentation/pages/resident_detail_page.dart';
import '../presentation/pages/resident_create_page.dart';

class ResidentRoutes {
  static const String list = '/resident';
  static const String detail = '/resident/:id';
  static const String create = '/resident/create';

  static List<RouteBase> get all => [
    GoRoute(
      path: list,
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
}
```

### Step 5: Update resident_module.dart

```dart
/// Resident Module
library resident_module;

export 'public_api.dart';
export 'module/resident_module_definition.dart';
export 'manifest/manifest.dart';
```

### Step 6: Update Shell Integration

```dart
// In rt-rw-digital/lib/main.dart
import 'package:resident_module/resident_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final registry = ModuleRegistry();
  registry.register(ResidentModule());

  // ... rest of bootstrap
}
```

## 3. Module Contract File

Create `module_manfiest.yaml` at resident_module root:

```yaml
name: resident
display_name: "Resident Management"
version: 1.0.0
description: "Manage resident profiles, phone numbers, and email addresses"
min_shell_version: 1.0.0

dependencies:
  - module: core_module
    min_version: 1.0.0
    optional: false

permissions:
  - name: "resident.read"
    description: "View resident profiles"
  - name: "resident.write"
    description: "Create and update residents"
  - name: "resident.delete"
    description: "Remove residents"

routes:
  - path: "/resident"
    name: "resident.list"
    requires_auth: true
  - path: "/resident/:id"
    name: "resident.detail"
    requires_auth: true
  - path: "/resident/create"
    name: "resident.create"
    requires_auth: true
    permissions: ["resident.write"]

feature_flags:
  resident.enabled: true
  resident.visible: true
  resident.export: false

provides:
  - "resident.crud"
  - "resident.search"
```

## 4. Resulting resident_module Structure

```
resident_module/
├── lib/
│   ├── resident_module.dart
│   ├── public_api.dart
│   ├── module/
│   │   └── resident_module_definition.dart
│   ├── manifest/
│   │   └── manifest.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   └── resident.dart
│   │   └── repositories/
│   │       └── resident_repository.dart
│   ├── application/
│   │   ├── usecases/           (future)
│   │   ├── repositories/
│   │   │   └── resident_repository_impl.dart
│   │   ├── services/           (future)
│   │   └── models/
│   │       └── resident_model.dart
│   ├── infrastructure/
│   │   ├── datasource/         (future: API, local DB)
│   │   ├── repositories/       (future)
│   │   ├── dto/                (future)
│   │   └── mapper/             (future)
│   ├── presentation/
│   │   ├── bloc/               (future)
│   │   ├── pages/
│   │   │   ├── resident_list_page.dart
│   │   │   ├── resident_detail_page.dart
│   │   │   └── resident_create_page.dart
│   │   └── widgets/            (future)
│   ├── routes/
│   │   └── resident_routes.dart
│   └── injection/
│       ├── resident_injection.dart
│       └── resident_injection.config.dart
├── test/
│   ├── domain/
│   ├── application/
│   ├── presentation/
│   └── integration/
├── pubspec.yaml
├── CHANGELOG.md
├── README.md
└── module_manifest.yaml
```

## 5. Key Changes Summary

1. **ADDED**: `module/resident_module_definition.dart` - implements FeatureModule
2. **ADDED**: `manifest/manifest.dart` - module metadata
3. **ADDED**: `routes/resident_routes.dart` - module-owned route definitions
4. **ADDED**: `module_manifest.yaml` - machine-readable manifest
5. **UPDATED**: `resident_module.dart` - exports module definition + manifest
6. **ADDED**: `presentation/pages/` - UI pages with placeholders
7. **UPDATED**: `pubspec.yaml` - added module_contracts dependency

Total new files: ~6
Total modified files: ~2
Estimated effort: 1-2 days for resident_module migration
