# AI-Agent Module Template

## 1. Template Purpose

AI agents should generate entire feature modules from this template.

Template ensures every module is:
- Self-describing
- Independently understandable
- Self-registering
- Properly structured

## 2. Module Directory Structure

```
{module_name}_module/
├── lib/
│   ├── {module_name}_module.dart          # Barrel export
│   ├── public_api.dart                     # Public API surface
│   ├── module/
│   │   └── {module_name}_module_definition.dart  # FeatureModule impl
│   ├── manifest/
│   │   └── manifest.dart                   # ModuleManifest definition
│   ├── domain/
│   │   ├── entities/                       # Domain entities
│   │   └── repositories/                   # Repository interfaces
│   ├── application/
│   │   ├── usecases/                       # Use cases
│   │   ├── repositories/                   # Repository implementations
│   │   ├── services/                       # Domain services
│   │   └── models/                         # Data models (DTOs)
│   ├── infrastructure/
│   │   ├── datasource/                     # Remote/local data sources
│   │   ├── repositories/                   # Infrastructure repos
│   │   ├── dto/                            # API DTOs
│   │   └── mapper/                         # Entity-DTO mappers
│   ├── presentation/
│   │   ├── bloc/                           # State management
│   │   ├── pages/                          # UI pages
│   │   └── widgets/                        # Reusable widgets
│   ├── routes/
│   │   └── {module_name}_routes.dart       # Route definitions
│   └── injection/
│       ├── {module_name}_injection.dart
│       └── {module_name}_injection.config.dart  # Generated
├── test/
│   ├── domain/                             # Domain unit tests
│   ├── application/                        # Use case tests
│   ├── infrastructure/                     # Data source tests
│   ├── presentation/                       # Widget tests
│   └── integration/                        # Integration tests
├── pubspec.yaml
├── CHANGELOG.md
├── README.md
└── module_manifest.yaml                    # Machine-readable manifest
```

## 3. AI-Agent Prompt Template

When generating a new module, use this prompt:

```
Generate a Flutter feature module named "{module_name}" following MFE-ready architecture.

Module Requirements:
- Feature name: {display_name}
- Description: {description}
- Domain entities: {list_of_entities}
- Routes: {list_of_routes}
- Permissions: {list_of_permissions}
- Dependencies: {list_of_dependencies}

Structure:
1. Implement FeatureModule contract
2. Create ModuleManifest with metadata
3. Define domain entities and repository interfaces
4. Implement repository with {data_source_type} data source
5. Create {state_management} blocs
6. Build UI pages
7. Register routes via FeatureModule.routes
8. Set up dependency injection with GetIt + injectable
9. Expose only public API in public_api.dart
10. Write unit tests for domain + use cases

Do NOT:
- Import other feature modules directly
- Depend on anything outside core_module + module_contracts
- Access shell-internal classes
```

## 4. Module Generation Checklist

AI agent verifies:

- [ ] `FeatureModule` interface implemented
- [ ] `ModuleManifest` defined with full metadata
- [ ] `routes` getter returns GoRouter configs
- [ ] `initialize()` handles async setup
- [ ] `setupDependencies()` registers DI
- [ ] `public_api.dart` exports only domain interfaces
- [ ] No direct imports of other feature modules
- [ ] All paths use `/{module_name}/...` convention
- [ ] Feature flags defined in manifest
- [ ] Permissions defined in manifest
- [ ] Tests exist for domain layer
- [ ] Tests exist for use cases
- [ ] `module_manifest.yaml` updated
- [ ] `CHANGELOG.md` updated

## 5. Template Files

### {module_name}_module.dart

```dart
/// {display_name} Module
library {module_name}_module;

export 'public_api.dart';
```

### public_api.dart

```dart
/// Public API for {module_name} module
library {module_name}_module;

// Export only domain abstractions
// export 'domain/entities/{entity}.dart';
// export 'domain/repositories/{repository}.dart';
```

### {module_name}_module_definition.dart

```dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:module_contracts/module_contracts.dart';

import '../injection/{module_name}_injection.dart';
import '../manifest/manifest.dart';
import '../routes/{module_name}_routes.dart';

class {ModuleName}Module implements FeatureModule {
  @override
  String get name => '{module_name}';

  @override
  String get displayName => '{display_name}';

  @override
  ModuleVersion get version => ModuleVersion(1, 0, 0);

  @override
  ModuleManifest get manifest => moduleManifest;

  @override
  Future<void> initialize() async {
    // Async initialization
  }

  @override
  List<RouteBase> get routes => {moduleName}Routes.all;

  @override
  List<ModulePermission> get permissions => moduleManifest.permissions;

  @override
  void setupDependencies() {
    setup{ModuleName}Injection();
  }
}
```

### manifest.dart

```dart
import 'package:module_contracts/module_contracts.dart';

final moduleManifest = ModuleManifest(
  name: '{module_name}',
  displayName: '{display_name}',
  version: ModuleVersion(1, 0, 0),
  description: '{description}',
  minShellVersion: ModuleVersion(1, 0, 0),
  permissions: [
    // ModulePermission(name: '{module_name}.read', description: '...'),
  ],
  dependencies: [
    ModuleDependency(moduleName: 'core_module', minVersion: ModuleVersion(1, 0, 0)),
  ],
  featureFlags: {{
    '{module_name}.enabled': true,
    '{module_name}.visible': true,
  }},
  provides: [
    '{module_name}.feature1',
  ],
);
```

### {module_name}_routes.dart

```dart
import 'package:go_router/go_router.dart';

class {ModuleName}Routes {
  static const String list = '/{module_name}';
  static const String detail = '/{module_name}/:id';
  static const String create = '/{module_name}/create';

  static List<RouteBase> get all => [
    GoRoute(
      path: list,
      name: '{module_name}.list',
      builder: (context, state) => const {ModuleName}ListPage(),
      routes: [
        GoRoute(
          path: ':id',
          name: '{module_name}.detail',
          builder: (context, state) => {ModuleName}DetailPage(
            id: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: 'create',
          name: '{module_name}.create',
          builder: (context, state) => const {ModuleName}CreatePage(),
        ),
      ],
    ),
  ];
}
```

### {module_name}_injection.dart

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '{module_name}_injection.config.dart';

@InjectableInit(
  initializerName: 'init{ModuleName}',
  preferRelativeImports: true,
  asExtension: true,
)
void setup{ModuleName}Injection() => GetIt.instance.init{ModuleName}();
```

### pubspec.yaml

```yaml
name: {module_name}_module
description: "{display_name} module"
version: 1.0.0

environment:
  sdk: ^3.10.9
  flutter: ">=1.17.0"

dependencies:
  flutter:
    sdk: flutter
  core_module:
    path: ../core_module
  module_contracts:
    path: ../module_contracts
  # Feature-specific packages...
```
