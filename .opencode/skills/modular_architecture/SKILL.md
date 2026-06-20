# Modular Architecture Rules

# Flutter Modular Architecture Skill

## Purpose

This project uses a modular multi-repository Flutter architecture.

Every business feature must be developed as an independent Flutter package/module that can be consumed by one or more applications.

The objective is:

* domain isolation
* independent development
* independent release
* reusability
* scalability

---

# Core Principles

A module owns a business domain.

Examples:

* resident\_module
* finance\_module
* forum\_module
* maps\_module
* appointment\_module

A module must be independently maintainable.

A module must never directly depend on another business module.

---

# Dependency Rules

Allowed:

```text
module
  ↓
core_module
```

Allowed:

```text
rt_rw_app
  ↓
resident_module

rt_rw_app
  ↓
forum_module
```

Forbidden:

```text
forum_module
  ↓
resident_module
```

Forbidden:

```text
maps_module
  ↓
resident_module
```

Forbidden:

```text
appointment_module
  ↓
forum_module
```

The application is responsible for connecting modules together.

---

# Module Ownership

Each module owns:

* domain entities
* use cases
* repository contracts
* presentation layer
* route definitions
* state management

A module must not own:

* global configuration
* application branding
* application routing composition
* API credentials
* environment configuration

These belong to the application layer.

---

# Standard Module Structure

```text
module_name/

├── lib/
│
├── public_api.dart
│
├── module.dart
│
└── src/
    │
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    │
    ├── data/
    │   ├── datasource/
    │   ├── dto/
    │   └── repositories/
    │
    ├── presentation/
    │   ├── pages/
    │   ├── widgets/
    │   └── bloc/
    │
    ├── routes/
    │
    └── di/
```

---

# Public API Rules

Consumers may only import:

```dart
import 'package:module_name/public_api.dart';
```

Forbidden:

```dart
import 'package:module_name/src/...';
```

Internal implementation must remain private.

---

# Routing Rules

Each module owns its own route definitions.

Example:

```dart
class ResidentModule {
  static List<RouteBase> routes() {
    return ResidentRoutes.routes;
  }
}
```

Application composes routes.

Example:

```dart
GoRouter(
  routes: [
    ...ResidentModule.routes(),
    ...ForumModule.routes(),
    ...MapsModule.routes(),
  ],
);
```

Modules must not directly register themselves into the application's router.

---

# Dependency Injection Rules

Modules must depend on abstractions only.

Allowed:

```dart
abstract class ResidentRepository {}
```

Forbidden:

```dart
final dio = Dio();
```

Forbidden:

```dart
FirebaseFirestore.instance
```

Forbidden:

```dart
Supabase.instance.client
```

Infrastructure dependencies must be injected by the application.

---

# Repository Rules

Modules define contracts.

Example:

```dart
abstract class ResidentRepository {
  Future<List<Resident>> getResidents();
}
```

Applications provide implementations.

Example:

```dart
class ResidentApiRepository
    implements ResidentRepository {}
```

---

# Native Platform Rules

Reusable platform capabilities may exist inside modules:

* share
* camera
* file picker
* biometric
* permissions

Application-specific integrations must remain in the application layer:

* API keys
* Firebase projects
* Analytics configuration
* Deep link schemes
* Environment configuration

---

# Application Responsibilities

Applications act as composition roots.

Applications are responsible for:

* dependency injection
* module wiring
* configuration
* environment setup
* authentication bootstrap
* route composition

Applications must not contain business logic that belongs to modules.

---

# Validation Checklist

Before creating or modifying a module verify:

* module owns a single business domain
* module does not depend on another business module
* module exposes a public API
* module owns its presentation layer
* module defines repository contracts
* infrastructure is injected
* routing is self-contained
* application remains the composition root

If any rule is violated:

STATUS: NEEDS\_REVISION

```

```

Each module must be independently releasable.

Modules must not depend on other business modules.

Allowed:

forum_module
-> core_module

maps_module
-> core_module

resident_module
-> core_module

Forbidden:

forum_module
-> resident_module

maps_module
-> resident_module

appointment_module
-> forum_module

Communication between modules must happen through:

- Contracts
- Public APIs
- Composition Root

The application layer is responsible for wiring modules together.
