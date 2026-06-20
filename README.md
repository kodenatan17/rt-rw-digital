# RT-RW Digital

A modern, AI-assisted application to simplify and digitize neighborhood administration (RT/RW).

Built with **MFE-Ready Modular Monolith** architecture — each feature is an independent module that self-registers into the shell via a shared contract system.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         rt-rw-digital (Shell)                                    │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                        Shell Layer                                         │  │
│  │  main.dart · AppBootstrap · ModuleRegistry · GoRouter                     │  │
│  │  AuthTokenStore · GrowthBookService · DashboardPage                       │  │
│  └──────────┬───────────────────────────────────────────────────┬────────────┘  │
│             │ depends on                                        │ depends on     │
│  ┌──────────▼──────────┐   ┌──────────────────────┐   ┌───────▼───────────────┐ │
│  │    core_module       │   │ authentication_module │   │   resident_module     │ │
│  │  (Contract Library)  │   │   (Feature Module)    │   │   (Feature Module)    │ │
│  │                      │   │                       │   │                       │ │
│  │  FeatureModule       │   │  AuthBloc · LoginPage │   │  Resident CRUD Pages  │ │
│  │  ModuleManifest      │   │  OtpVerificationPage  │   │  ResidentRepository   │ │
│  │  ModuleInitStrategy  │   │  AuthRepository       │   │                       │ │
│  │  ModuleVersion       │   │                       │   │                       │ │
│  │  VersionCompatibility│   │  (eager, required)    │   │  (lazy, optional)     │ │
│  └──────────────────────┘   └───────────────────────┘   └───────────────────────┘ │
│                                                                                  │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │              Future Modules (lazy init)                                    │  │
│  │  finance_module · complaint_module · meeting_module                        │  │
│  │  notification_module · analytics_module · report_module                   │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

### Key Principles

- **Feature-Driven** — organized by domain, not layers
- **Clean Architecture** — domain → application → infrastructure → presentation
- **Contract-First** — `FeatureModule` contract defines every module boundary
- **Self-Registering** — modules provide their own routes, DI, manifests
- **Offline-First Bootstrap** — GrowthBook NEVER blocks startup; uses cached flags + manifest defaults
- **Progressive Initialization** — eager modules block, warmup runs after first frame, lazy modules init on first access
- **Version-Gated** — shell checks compatibility before loading modules

---

## Project Structure

```
rt-rw-digital/
├── lib/
│   ├── main.dart                           # App entry, module registration, routing, auth
│   ├── auth_token_store.dart               # Auth token persistence (Hive + SecureStorage)
│   ├── bootstrap/
│   │   └── app_bootstrap.dart              # Offline-first bootstrap + PostBootstrapExtension
│   ├── core/
│   │   ├── module_registry/
│   │   │   └── module_registry.dart        # Central registry + BootstrapMetrics
│   │   ├── feature_flags/
│   │   │   ├── feature_flag_service.dart    # FeatureFlagRepository impl (offline-first)
│   │   │   ├── growthbook_service.dart      # GrowthBook SDK lifecycle
│   │   │   └── growthbook_feature_flag_source.dart # GrowthBook → RemoteSource bridge
│   │   └── env/
│   │       ├── env_config.dart            # Envied-annotated credentials
│   │       └── env_config.g.dart          # Generated (gitignored)
│   └── injection/
│       └── app_injection.dart             # App-level DI
├── solutioning/
│   ├── architecture/                      # ADRs, diagrams, migration roadmap
│   ├── api-contract/                      # OpenAPI 3.0 spec
│   ├── forum/                             # Forum feature spec
│   ├── maps/                              # Maps feature spec
│   ├── iuran/                             # Iuran feature spec
│   ├── kas/                               # Kas feature spec
│   ├── acara/                             # Acara feature spec
│   └── profil/                            # Profil feature spec
├── android/
│   └── app/
│       └── build.gradle.kts              # ndkVersion = "27.0.12077973"
├── pubspec.yaml
└── README.md
```

---

## Progressive Module Initialization

The app uses a **Register All → Init Eager → Warmup → Lazy** strategy.
Startup NEVER blocks on remote feature flags — uses cached flags + manifest defaults.

### Bootstrap Sequence (Offline-First)

```
App Start
  ↓
Register All Modules              → metadata/routes/menus ready instantly
  ↓
Version Compatibility Check
  ↓
Load Cached Feature Flags         → from local storage (non-blocking)
  ↓
DI Setup (all enabled modules)    → core → authentication → resident → ...
  ↓
Init Eager Modules                → authentication, dashboard
  ↓
App Ready ✅ — UI visible to user
  ↓  (background, non-blocking)
Init GrowthBook SDK               → if API key available
  ↓
Refresh Remote Flags              → fetch from GrowthBook
  ↓
Persist to Cache                  → apply on next cold start
  ↓
Schedule Warmup Modules           → notification, chat, maps
  ↓
BootstrapMetrics.printReport()
```

### Module Initialization Strategy

| Strategy | Init Timing             | StartupBehavior  | Examples                          |
|----------|-------------------------|------------------|-----------------------------------|
| `eager`  | Startup (blocking)      | required         | authentication, dashboard         |
| `warmup` | Post-first-frame (bg)   | optional         | notification, chat, maps, forum   |
| `lazy`   | On first access         | optional         | resident, reports, analytics      |

Set via manifest:
```dart
ModuleManifest(
  name: 'authentication',
  initializationStrategy: ModuleInitializationStrategy.eager,
  startupBehavior: StartupBehavior.required,
  defaultEnabled: true,
  defaultVisible: false,
)
```

### Offline-First Feature Flag Resolution

```
Remote Override (GrowthBook)
  ↓  (if available)
Local Cached Flags
  ↓  (if remote unavailable)
ModuleManifest Defaults
```

Resolution order:
1. **Remote flags** — GrowthBook API (highest priority)
2. **Cached flags** — from previous successful fetch
3. **Manifest defaults** — `defaultEnabled`, `defaultVisible` (fallback)

**GrowthBook NEVER blocks startup.** Remote refresh happens in background
after the app is visible. Manifest defaults always work.

### Module Lifecycle

```dart
registry.register(module);              // lightweight — metadata available
registry.initializeModule(name);        // one-time async init (idempotent)
registry.disposeModule(name);           // resource cleanup
registry.isModuleInitialized(name);     // check state

// Bulk operations by strategy
registry.initializeByStrategy(ModuleInitializationStrategy.eager);
registry.scheduleWarmup();              // after first frame
registry.disposeAll();
```

### Performance Metrics

After bootstrap + warmup, the console prints:

```
══════════════════════════════════════════════
  Bootstrap Report
══════════════════════════════════════════════
  Total duration:  123 ms
  Registration:    5 ms
  DI setup:        15 ms
  Initialization:  45 ms
  Registered:      10 module(s)
  Initialized:     3 module(s)
──────────────────────────────────────────────
  authentication         42 ms
  resident               38 ms
  dashboard              25 ms
══════════════════════════════════════════════
```

Access programmatically via `registry.metrics`.

---

## Authentication Flow

Owned by `authentication_module`. The shell provides route guards and token persistence.

### Login

```
GET  /login    → LoginPage (phone + password)
POST /auth/login API → AuthResponse (token + user)
     ↓
Token stored in Hive (authentication_module's AuthRepositoryImpl)
     ↓
Redirect to / (Dashboard)
```

### OTP Verification (after registration)

```
GET  /register-verify?phone=xxx → OtpVerificationPage
POST /auth/register/verify API → AuthResponse
     ↓
Token stored, redirect to /
```

### Route Guard

GoRouter redirect interceptor checks `AuthBloc.state`:

```
State is AuthAuthenticated   → allow navigation
State is AuthUnauthenticated → redirect to /login
```

Auth routes (`/login`, `/register-verify`) are placed **outside** the ShellRoute (no navigation drawer).

### Auth Architecture

```
main.dart
  │
  ├─ AppBootstrap.run()           → setupAuthenticationInjection() → AuthBloc registered
  ├─ AuthTokenStore.init()        → shell-level Hive storage (optional)
  └─ RtRwApp (BlocProvider<AuthBloc>)
       │
       ├─ GoRouter (refreshListenable → AuthRedirectNotifier)
       │    └─ _authRedirect()     → /login if unauthenticated
       │
       └─ DashboardPage
            └─ context.watch<AuthBloc>() → show user name + logout button
```

---

## How to Run

### Prerequisites

- Flutter SDK `^3.8.1`
- Dart SDK `^3.8.1`
- iOS 12+ / Android 21+
- Android NDK `27.0.12077973` (set in `android/app/build.gradle.kts`)

### 1. Clone & Install

```bash
git clone <repo-url>
cd rt-rw-digital
flutter pub get
```

### 2. Environment Variables (Optional)

```bash
cp .env.example .env
# Edit .env with GrowthBook API key if using remote feature flags
```

### 3. Generate Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run

```bash
flutter run
```

### Build for Release

```bash
flutter build ios
flutter build apk --release
```

---

## How to Add a New Module

Step-by-step guide to create and register a new feature module (e.g. `FinanceModule`).

### 1. Create the Module Package

Create a new Dart package under the repo root:

```
finance_module/
├── lib/
│   ├── finance_module.dart               # Barrel exports
│   ├── public_api.dart                   # Domain abstractions only
│   ├── manifest/
│   │   └── manifest.dart                 # ModuleManifest instance
│   ├── module/
│   │   └── finance_module_definition.dart # FeatureModule implementation
│   ├── domain/
│   │   ├── entities/                     # Domain models
│   │   └── repositories/                # Abstract repository contracts
│   ├── application/                      # Use cases, services, models
│   ├── infrastructure/                   # Data sources, API clients
│   ├── injection/
│   │   ├── finance_injection.dart        # DI setup
│   │   └── finance_injection.config.dart # Generated by injectable
│   ├── routes/
│   │   └── finance_routes.dart           # GoRouter routes
│   └── presentation/
│       ├── bloc/                         # BLoC state management
│       ├── pages/                        # UI screens
│       └── widgets/                      # Reusable widgets
├── test/
├── pubspec.yaml                          # Depends on core_module
├── CHANGELOG.md
└── README.md
```

### 2. Define Manifest

```dart
// lib/manifest/manifest.dart
import 'package:core_module/core_module.dart';

final financeManifest = ModuleManifest(
  name: 'finance',
  displayName: 'Finance Management',
  version: ModuleVersion(1, 0, 0),
  description: 'Manage iuran and kas transactions',
  initializationStrategy: ModuleInitializationStrategy.lazy,
  startupBehavior: StartupBehavior.optional,
  defaultEnabled: true,
  defaultVisible: true,
  dependencies: [
    ModuleDependency(
      moduleName: 'core_module',
      minVersion: ModuleVersion(1, 0, 0),
    ),
  ],
);
```

### 3. Implement FeatureModule

```dart
// lib/module/finance_module_definition.dart
import 'package:core_module/core_module.dart';
import 'package:go_router/go_router.dart';

class FinanceModule extends FeatureModule {
  bool _initialized = false;

  @override
  String get name => 'finance';
  @override
  String get displayName => 'Finance Management';
  @override
  ModuleVersion get version => ModuleVersion(1, 0, 0);
  @override
  ModuleManifest get manifest => financeManifest;
  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    // DB migrations, preload data, API init, etc.
    _initialized = true;
  }

  @override
  void dispose() { _initialized = false; }

  @override
  void setupDependencies() { setupFinanceInjection(); }

  @override
  List<RouteBase> get routes => FinanceRoutes.all;
}
```

### 4. Create Routes

```dart
// lib/routes/finance_routes.dart
import 'package:go_router/go_router.dart';

class FinanceRoutes {
  static const String list = '/finance';

  static List<RouteBase> get all => [
    GoRoute(
      path: list,
      name: 'finance.list',
      builder: (context, state) => const FinanceListPage(),
      routes: [
        // Nested routes...
      ],
    ),
  ];
}
```

### 5. Set Up DI

```dart
// lib/injection/finance_injection.dart
import 'package:core_module/injection/core_injection.dart';
import 'package:injectable/injectable.dart';
import 'finance_injection.config.dart';

@InjectableInit(
  initializerName: 'initFinance',
  preferRelativeImports: true,
  asExtension: true,
)
void setupFinanceInjection() => getIt.initFinance();
```

### 6. Register in Shell

```dart
// In rt-rw-digital/lib/main.dart
final modules = <FeatureModule>[
  AuthenticationModule(),   // eager, required
  ResidentModule(),         // lazy, optional
  FinanceModule(),          // <-- add the new module here
];
```

### 7. Add Dependency in `pubspec.yaml`

```yaml
# rt-rw-digital/pubspec.yaml
dependencies:
  finance_module:
    path: ../finance_module
```

### 8. Strategy Selection Guide

| Strategy | StartupBehavior | When to Use                                      |
|----------|-----------------|--------------------------------------------------|
| `eager`  | `required`      | Module needed on first screen (authentication)   |
| `warmup` | `optional`      | Visible in nav but not instant (notification)    |
| `lazy`   | `optional`      | Deep nav or rare access (reports, resident)      |

### 9. Barrel Export

```dart
// lib/finance_module.dart
export 'public_api.dart';
export 'module/finance_module_definition.dart';
export 'manifest/manifest.dart';
```

```dart
// lib/public_api.dart
export 'domain/entities/...';
export 'domain/repositories/...';
```

---

## Core Components

### Shell (`main.dart`)

- Defines `shellVersion = ModuleVersion(1, 0, 0)`
- Runs `AppBootstrap.run(modules: [...])` (4-phase progressive bootstrap)
- Creates `AuthBloc` from GetIt, wraps app in `BlocProvider`
- Builds `MaterialApp.router` with `GoRouter` + auth redirect
- Auth routes (`/login`, `/register-verify`) **outside** ShellRoute
- Module routes auto-composed from `registry.allRoutes`
- `_scheduleWarmup(registry)` called after first frame
- Dashboard shows user name + logout button (wired to `AuthBloc`)

### Bootstrap (`AppBootstrap`)

Offline-first bootstrap (GrowthBook NEVER blocks startup):

1. **Register All** — `registry.registerAll(modules)` — metadata/routes ready instantly
2. **Version Compatibility** — shell version check
3. **Load Cached Flags** — `featureFlagService.loadCached()` (non-blocking)
4. **DI Setup** — `setupCoreInjection()` + per-module `setupDependencies()` (core → authentication → resident → ...)
5. **Init Eager** — `registry.initializeByStrategy(ModuleInitializationStrategy.eager)`

Returns `BootstrapResult` with registry + metrics + compat results.
On failure: shows `ForcedUpdateApp` fallback screen.

**PostBootstrapExtension** — call after first frame:
- `registry.scheduleWarmup()` — init warmup modules in background
- `registry.scheduleBackgroundRefresh()` — fetch remote flags from GrowthBook
- `registry.metrics.printReport()` — view timing summary

### Module Registry (`ModuleRegistry`)

Central registry managing all feature modules with progressive initialization.

| Method / Getter               | Description                                    |
|-------------------------------|------------------------------------------------|
| `register(module)`            | Register single module (lightweight)           |
| `registerAll(list)`           | Register multiple modules                      |
| `enabledModules`              | Only enabled modules                           |
| `allModules`                  | All registered modules                         |
| `allRoutes`                   | Routes from enabled modules                    |
| `eagerModules`                | Enabled modules with strategy=eager            |
| `warmupModules`               | Enabled modules with strategy=warmup           |
| `lazyModules`                 | Enabled modules with strategy=lazy             |
| `initializeModule(name)`      | Init single module (idempotent)                |
| `initializeByStrategy(s)`     | Init all modules of a given strategy           |
| `setupModuleDependencies(name)`| DI setup for a single module                  |
| `setupAllDependencies()`      | DI setup for all enabled modules               |
| `disposeModule(name)`         | Release resources for a module                 |
| `disposeAll()`                | Release all module resources                   |
| `isModuleInitialized(name)`   | Check if module has been initialized           |
| `isEnabled(name)`             | Check enable state                             |
| `isVisible(name)`             | Check visibility for menu                      |
| `checkCompatibility()`        | Run version checks                             |
| `featureFlagService`          | Current `FeatureFlagService` instance          |
| `metrics`                     | `BootstrapMetrics` with timing data            |

Enable/disable resolution order:
1. Manual override (`enable()`/`disable()`)
2. Feature flag service (remote → cache)
3. Manifest default (`defaultEnabled`)

### Feature Flags (`FeatureFlagService`)

Implements `FeatureFlagRepository`. Controls module and feature visibility with offline-first resolution.

**Resolution Order:**
1. **Remote flags** — GrowthBook API (highest priority)
2. **Cached flags** — from previous successful fetch
3. **Manifest defaults** — `defaultEnabled` / `defaultVisible`

**Offline-First Guarantees:**
- `loadCached()` — reads from local cache, NEVER throws
- `refreshRemote()` — safe to call anytime, never blocks UI
- GrowthBook unavailability **NEVER blocks app startup**
- Manifest defaults always work when both remote and cache are unavailable

**Key Methods:**
| Method               | Description                                |
|----------------------|--------------------------------------------|
| `loadCached()`       | Load flags from local cache (instant)      |
| `refreshRemote()`    | Fetch remote flags + persist to cache      |
| `isEnabled(key)`     | Check single flag (remote → cache → true)  |
| `isModuleEnabled(name)` | Check module enabled state             |
| `isModuleVisible(name)` | Check module menu visibility            |
| `resolveFlags()`     | All effective flags                        |

**Important**: `GrowthBookFeatureFlagSource` skips features with source `unknownFeature` (not defined on server). This ensures flags missing from GrowthBook fall back to manifest defaults rather than returning `false`.

### Auth Token Store (`auth_token_store.dart`)

Shell-level token persistence using Hive (AES-encrypted) + FlutterSecureStorage.

- `init()` — opens encrypted Hive box
- `saveTokens(accessToken, refreshToken)` — persists tokens
- `clear()` — removes all tokens
- `ValueNotifier<AuthTokens?>` — reactive auth state

> Note: `authentication_module` has its own Hive-based token storage in `AuthRepositoryImpl`. The shell-level store is kept for compatibility and future refresh-token flows.

---

## Project Dependencies

| Package                    | Purpose                          |
|----------------------------|----------------------------------|
| `core_module`              | Contracts, base classes, Dio     |
| `authentication_module`    | Login, OTP, session management   |
| `resident_module`          | Resident CRUD                    |
| `flutter_bloc`             | State management                 |
| `go_router`                | Declarative routing              |
| `get_it` + `injectable`    | Dependency injection             |
| `dio`                      | HTTP client                      |
| `hive` + `hive_flutter`    | Local storage                    |
| `flutter_secure_storage`   | Encrypted key storage            |
| `growthbook_sdk_flutter`   | Feature flag SDK                 |
| `envied`                   | Compile-time env vars            |
| `json_serializable`        | JSON codegen                     |
| `equatable`                | Value equality                   |

---

## Solutioning Docs

Located in `solutioning/`:

- `architecture/` — ADRs, diagrams, migration roadmap, gap analysis
- `api-contract/api-contract.yaml` — OpenAPI 3.0 spec for all endpoints
- `forum/` — Feature spec, domain model, API contract, workflows
- `maps/` — Maps feature documentation
- `iuran/` — Iuran feature documentation
- `kas/` — Kas feature documentation
- `acara/` — Acara feature documentation
- `profil/` — Profil feature documentation

---

## Troubleshooting

### NDK Build Failure

If you see:
```
The CMAKE_C_COMPILER ... is not a full path to an existing compiler tool.
```

Make sure `android/app/build.gradle.kts` has:
```kotlin
ndkVersion = "27.0.12077973"
```

And NDK 27 is installed via Android Studio SDK Manager.

### AuthBloc Not Registered

If you see:
```
Bad state: GetIt: Object/factory with type AuthBloc is not registered inside GetIt.
```

This means either:
1. GrowthBook returned `authentication.enabled = false` — check your GrowthBook dashboard
2. The `setupAuthenticationInjection()` was skipped because the module was disabled
3. Re-run with `flutter clean && flutter pub get && flutter run`

### GrowthBook Flags Returning False

If remote flags override manifest defaults with `false`:
- Check that the feature exists on the GrowthBook server
- If it doesn't exist, `GrowthBookFeatureFlagSource` now skips it (source = `unknownFeature`)
- The app falls back to manifest defaults
