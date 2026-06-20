# RT-RW Digital

A modern, AI-assisted application to simplify and digitize neighborhood administration (RT/RW).

Built with **Modular Monolith** architecture — each feature is an independent module that self-registers into the shell via a shared contract system.

---

## Architecture Overview

```
┌──────────────────────────────────────────────────┐
│                   rt-rw-digital                   │
│  ┌────────────────────────────────────────────┐  │
│  │              Shell (App Shell)              │  │
│  │  ModuleRegistry · Bootstrap · FeatureFlags  │  │
│  │  GoRouter · Navigation Drawer · Dashboard   │  │
│  └──────┬──────────────────────────┬───────────┘  │
│         │ depends on               │ depends on    │
│  ┌──────▼──────────┐   ┌──────────▼───────────┐  │
│  │  core_module     │   │   resident_module     │  │
│  │  (Contracts)     │   │   (Feature Module)    │  │
│  └─────────────────┘   └──────────────────────┘  │
│         │                     │                   │
│  ┌──────▼──────────┐   ┌──────────▼───────────┐  │
│  │  Finance Module  │   │   Complaint Module    │  │
│  │  (future)        │   │   (future)            │  │
│  └─────────────────┘   └──────────────────────┘  │
└──────────────────────────────────────────────────┘
```

### Key Principles

- **Feature-Driven** — organized by domain, not layers
- **Clean Architecture** — domain → application → infrastructure → presentation
- **Contract-First** — `FeatureModule` contract defines every module boundary
- **Self-Registering** — modules provide their own routes, DI, manifests
- **Version-Gated** — shell checks compatibility before loading modules

---

## Project Structure

```
rt-rw-digital/
├── lib/
│   ├── main.dart                         # App entry, module registration, routing
│   ├── auth_token_store.dart             # Auth token persistence
│   ├── bootstrap/
│   │   └── app_bootstrap.dart            # Bootstrap sequence orchestrator
│   ├── core/
│   │   ├── commons/                      # Shared utilities (extendable)
│   │   ├── module_registry/
│   │   │   └── module_registry.dart      # Central module registry
│   │   ├── env/
│   │   │   ├── env_config.dart           # Envied-annotated credentials
│   │   │   └── env_config.g.dart         # Generated (gitignored)
│   │   └── feature_flags/
│   │       ├── feature_flags.dart        # Barrel export
│   │       ├── feature_flag_service.dart # Remote + local flag management
│   │       ├── growthbook_service.dart   # GrowthBook SDK lifecycle
│   │       └── growthbook_feature_flag_source.dart # GrowthBook → RemoteSource bridge
│   └── injection/
│       └── app_injection.dart            # App-level DI
├── solutioning/
│   └── architecture/                     # Architecture decision records
├── pubspec.yaml
└── README.md
```

---

## How to Run

### Prerequisites

- Flutter SDK `^3.8.1`
- Dart SDK `^3.8.1`
- iOS 12+ / Android 21+
- (Optional) GrowthBook account for feature flags

### 1. Environment Variables

Copy `.env.example` to `.env` and fill in your API credentials:

```bash
cp .env.example .env
```

Edit `.env`:

```env
GROWTHBOOK_API_KEY=sdk-your-api-key-here
GROWTHBOOK_HOST_URL=https://cdn.growthbook.io
```

> ⚠️ Never commit `.env` — it contains secrets. The file is gitignored.

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

Envied + injectable + json_serializable:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run Tests

```bash
flutter test
```

### 5. Run App

```bash
# Feature flags use values from .env (or manifest defaults if .env is empty)
flutter run
```

### Build for Release

```bash
flutter build ios
flutter build apk
```

> Builds use the `.env` values embedded at compile time via Envied codegen.

### Adding New API Credentials

1. Add variable to `.env` (e.g. `MIXPANEL_TOKEN=xxx`)
2. Add field in `lib/core/env/env_config.dart`:
   ```dart
   @EnviedField(varName: 'MIXPANEL_TOKEN')
   static final String mixpanelToken = _EnvConfig.mixpanelToken;
   ```
3. Re-run `dart run build_runner build`

---

## Core Components

### Shell (`main.dart`)

- Defines `shellVersion = ModuleVersion(1, 0, 0)`
- Runs `AppBootstrap.run(modules: [...])`
- Builds `MaterialApp.router` with `GoRouter`
- `ShellRoute` wraps `AppShell` (navigation drawer)
- Routes auto-composed from `registry.allRoutes`
- Dashboard page lists all enabled modules

### Bootstrap (`AppBootstrap`)

Sequential bootstrap:

1. Register modules into `ModuleRegistry`
2. Load feature flags (remote → cache)
3. Check version compatibility (blocking if incompatible)
4. Set up DI (`setupCoreInjection()` + per-module `setupDependencies()`)
5. Initialize modules (`registry.initializeAll()`)
6. Return `BootstrapResult` with registry + flags + compat results

On failure: shows `ForcedUpdateApp` fallback screen.

### Module Registry (`ModuleRegistry`)

Central registry managing all feature modules.

| Method               | Description                         |
|----------------------|-------------------------------------|
| `register(module)`   | Register single module              |
| `registerAll(list)`  | Register multiple modules           |
| `enabledModules`     | Only enabled modules                |
| `allModules`         | All registered modules              |
| `allRoutes`          | Routes from enabled modules         |
| `isEnabled(name)`    | Check enable state                  |
| `isVisible(name)`    | Check visibility for menu           |
| `initializeAll()`    | Init all enabled modules            |
| `checkCompatibility()`| Run version checks                 |

Enable/disable resolution order:
1. Manual override (`enable()`/`disable()`)
2. Feature flag service (remote flags)
3. Default from manifest

### Feature Flags (`FeatureFlagService`)

Controls module and feature visibility remotely.

Resolution priority:
1. Remote flags (API fetch) — highest
2. Local overrides (debug only)
3. Default values from module manifests

Supports `Stream<FlagChange>` for reactive UI updates.

### Module Contracts (`core_module`)

All contracts defined in `core_module/lib/contracts/`:

| Contract               | Role                                |
|------------------------|-------------------------------------|
| `FeatureModule`        | Abstract base for every module      |
| `ModuleManifest`       | Self-describing module metadata     |
| `ModuleVersion`        | Semantic version (MAJOR.MINOR.PATCH)|
| `ModuleDependency`     | Inter-module dependency declaration |
| `ModulePermission`     | Permission a module requires        |
| `ModuleRouteDefinition`| Route metadata for documentation    |
| `VersionCompatibility` | Shell ↔ module version checker      |

---

## How to Add a New Module

### 1. Create Module Package

```
finance_module/
├── lib/
│   ├── finance_module.dart
│   ├── public_api.dart
│   ├── manifest/manifest.dart
│   ├── module/finance_module_definition.dart
│   ├── domain/entities/
│   ├── domain/repositories/
│   ├── application/usecases/
│   ├── infrastructure/datasource/
│   ├── infrastructure/repositories/
│   ├── injection/finance_injection.dart
│   ├── routes/finance_routes.dart
│   └── presentation/pages/
├── pubspec.yaml  # depends on core_module
└── test/
```

### 2. Implement FeatureModule

```dart
class FinanceModule extends FeatureModule {
  @override String get name => 'finance';
  @override String get displayName => 'Finance Management';
  @override ModuleVersion get version => ModuleVersion(1, 0, 0);
  @override ModuleManifest get manifest => financeManifest;
  @override Future<void> initialize() async {}
  @override void setupDependencies() { setupFinanceInjection(); }
  @override List<RouteBase> get routes => FinanceRoutes.all;
}
```

### 3. Register in Shell

```dart
// main.dart
final result = await AppBootstrap.run(
  modules: [
    ResidentModule(),
    FinanceModule(),
  ],
  shellVersion: shellVersion,
);
```

### 4. Add Dependency

```yaml
# pubspec.yaml
dependencies:
  finance_module:
    path: ../finance_module
```

No other wiring needed — routes, manifests, permissions, and feature flags auto-register.

> **Feature Flag Keys**: Each key in `manifest.featureFlags` (e.g. `resident.enabled`)
> must match the feature key created in GrowthBook dashboard for remote control.
> If no GrowthBook API key is configured, manifest defaults are used.

---

## Feature Modules

| Module              | Status   | Description                        |
|---------------------|----------|------------------------------------|
| Resident            | Active   | Resident CRUD, search, profiles    |
| Finance             | Planned  | Iuran tracking, reports            |
| Complaint           | Planned  | Complaint submission & tracking    |
| Meeting             | Planned  | Meeting scheduling & minutes       |
| Security            | Planned  | Security post & visitor management |

---

## Dependencies

| Package                    | Purpose                      |
|----------------------------|------------------------------|
| `core_module`              | Module contracts, base layer |
| `resident_module`          | Resident feature module      |
| `go_router`                | Declarative routing          |
| `flutter_bloc`             | State management             |
| `get_it` + `injectable`    | Dependency injection         |
| `dio` + `retrofit`         | HTTP networking              |
| `hive_flutter`             | Local storage                |
| `flutter_secure_storage`   | Secure token storage         |
| `firebase_core` + `firebase_messaging` | Push notifications|
| `flutter_callkit_incoming` | VoIP/call handling           |
| `connectivity_plus`        | Network status monitoring    |
| `intl`                     | Localization / formatting    |
| `cached_network_image`     | Image caching                |
| `json_annotation`          | JSON serialization           |
| `equatable`                | Value equality               |
| `chucker_flutter`          | Debug HTTP inspector         |
| `growthbook_sdk_flutter`   | Feature flags & A/B testing  |
| `envied`                  | Env credential codegen       |

---

## Future Enhancements

- Mobile-first improvements
- Notification system (reminders, approvals)
- Advanced reporting & analytics
- Role-based access control
- Cloud synchronization
- More feature modules (finance, complaints, meetings, security)

---

## License

Open for development and adaptation based on community needs.
