# Recommended Architecture: MFE-Ready Modular Monolith

## Architecture Philosophy

Keep modular monolith. Add MFE-readiness patterns without over-engineering.

**Key principle**: Every module is a self-contained, self-describing unit that registers itself with a central registry. The shell only knows about the registry, not individual modules.

## Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│                    SHELL LAYER                       │
│  ModuleRegistry  │  App Bootstrap  │  Shell UI       │
│  FeatureFlag     │  GoRouter       │  ErrorHandler   │
└─────────────────────────────────────────────────────┘
         │                    │                │
         ▼                    ▼                ▼
┌─────────────────────────────────────────────────────┐
│                 MODULE LAYER                          │
│                                                       │
│  ┌─────────────────┐  ┌─────────────────┐           │
│  │  ResidentModule  │  │  FinanceModule   │   ...     │
│  │  - FeatureModule │  │  - FeatureModule │           │
│  │  - Routes        │  │  - Routes        │           │
│  │  - DI Init       │  │  - DI Init       │           │
│  │  - Manifest      │  │  - Manifest      │           │
│  └─────────────────┘  └─────────────────┘           │
└─────────────────────────────────────────────────────┘
         │                    │                │
         ▼                    ▼                ▼
┌─────────────────────────────────────────────────────┐
│                SHARED KERNEL LAYER                    │
│  core_module (keep existing) + contracts package     │
│  - BaseUseCase    │  ResultEntity    │  Dio/Delphi   │
│  - ModuleContract │  EventBus        │  Shared Models │
└─────────────────────────────────────────────────────┘
```

## Package Structure (After Migration)

```
rt-rw/
├── rt-rw-digital/              # Shell Application
│   └── lib/
│       ├── main.dart            (bootstrap with registry)
│       ├── app/
│       │   ├── app.dart         (MaterialApp + GoRouter)
│       │   └── shell.dart       (shell scaffold)
│       ├── core/
│       │   ├── module_registry/
│       │   │   ├── module_registry.dart
│       │   │   └── module_manifest.dart
│       │   ├── feature_flags/
│       │   │   └── feature_flag_service.dart
│       │   └── compatibility/
│       │       └── version_compatibility.dart
│       ├── injection/
│       │   └── app_injection.dart
│       └── bootstrap/
│           └── app_bootstrap.dart
│
├── core_module/                 # Shared Kernel (keep)
│   └── lib/
│       ├── core_module.dart
│       ├── application/
│       ├── domain/
│       ├── infrastructure/
│       └── injection/
│
├── module_contracts/           # NEW: Shared contracts package
│   └── lib/
│       ├── module_contracts.dart
│       ├── src/
│       │   ├── feature_module.dart       (abstract contract)
│       │   ├── module_manifest.dart      (manifest model)
│       │   ├── module_route.dart         (route descriptor)
│       │   ├── module_permission.dart    (permission model)
│       │   └── version_checker.dart      (compatibility util)
│
├── resident_module/             # Feature Module
│   └── lib/
│       ├── resident_module.dart
│       ├── public_api.dart
│       ├── module/
│       │   └── resident_module_definition.dart  (FeatureModule impl)
│       ├── manifest/
│       │   └── manifest.dart                   (module metadata)
│       ├── domain/
│       ├── application/
│       ├── infrastructure/
│       ├── presentation/
│       ├── routes/
│       │   └── resident_routes.dart
│       └── injection/
│
├── finance_module/              # Future Module
├── complaint_module/            # Future Module
├── meeting_module/              # Future Module
└── security_module/             # Future Module
```

## Key Design Decisions

### Decision 1: Shared Kernel Strategy → Option A
**Keep current core_module + add contracts package**

Rationale:
- core_module already provides base classes (UseCase, ResultEntity, Dio) that work
- Splitting core_api/core_impl adds migration cost without immediate benefit
- Future migration to core_api/core_impl is possible later without breaking modules
- **contracts** package is NEW and lightweight - only interfaces and models

### Decision 2: Module Discovery → Compile-time Registration
Modules register themselves through initialization, not runtime scanning.

### Decision 3: Route Registration → Module-Owned GoRouter Configs
Each module returns `GoRouter` route configs that the shell combines.

### Decision 4: Feature Flags → Backend-Controlled with Local Cache
Feature flags fetched at startup, cached locally, control module visibility.

### Decision 5: Module Communication → Event Bus + Contract APIs
No direct module-to-module imports. Communication via events and shared contracts.
