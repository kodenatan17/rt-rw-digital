# Module Boundary Strategy

## 1. Core Rule

**Modules must not directly import each other.**

```
INVALID:
  resident_module → finance_module  (direct import)
  finance_module  → complaint_module (direct import)
  complaint_module → resident_module (direct import)

VALID:
  resident_module → core_module + module_contracts (shared kernel)
  finance_module  → core_module + module_contracts (shared kernel)

  resident_module --[event bus]--> finance_module
  finance_module  --[event bus]--> complaint_module
```

## 2. Communication Patterns

### Pattern A: Shared Kernel (module_contracts)

Lightweight contract package that modules reference.

```dart
// module_contracts/lib/src/resident_api.dart
abstract class ResidentApi {
  Future<Resident?> getById(String id);
  Future<List<Resident>> search(String query);
}

// resident_module provides implementation
// finance_module uses the abstract interface
```

### Pattern B: Event Bus

For loose coupling and one-to-many notifications.

```dart
// module_contracts/lib/src/event_bus.dart
class ModuleEventBus {
  void publish(ModuleEvent event);
  Stream<T> on<T extends ModuleEvent>();
}

// Events
class ResidentCreated extends ModuleEvent {
  final String residentId;
  final String name;
}

class PaymentCompleted extends ModuleEvent {
  final String module;
  final String referenceId;
}

// resident_module publishes ResidentCreated
// finance_module listens and auto-creates iuran record
```

### Pattern C: Module API Service

For request-response between modules.

```dart
// module_contracts/lib/src/module_api.dart
abstract class ModuleApi {
  Future<dynamic> call({
    required String targetModule,
    required String method,
    Map<String, dynamic>? params,
  });
}
```

## 3. Current Dependency Analysis

```
Current:
  rt-rw-digital → core_module (ok - shell depends on shared kernel)
  rt-rw-digital → resident_module (ok - shell needs to register)
  resident_module → core_module (ok - feature module depends on shared kernel)

Target (future modules):
  finance_module → core_module (ok)
  complaint_module → core_module (ok)
  meeting_module → core_module (ok)
  security_module → core_module (ok)

No direct module-to-module dependencies in target state.
```

## 4. Dependency Rules

```yaml
dependency_rules:
  shell:
    can_depend_on: [core_module, module_contracts]
    can_register: [all feature modules]
    cannot_depend_on: [feature module internals]

  feature_module:
    can_depend_on: [core_module, module_contracts]
    cannot_depend_on: [other feature modules]

  module_contracts:
    can_depend_on: []
    must_be: [pure Dart, no flutter dependency if possible]

  core_module:
    can_depend_on: [external packages (dio, get_it, etc.)]
    must_not_depend_on: [any feature module]
```

## 5. Enforcing Boundaries

```dart
// pubspec.yaml - resident_module
dependencies:
  flutter:
    sdk: flutter
  core_module:
    path: ../core_module
  module_contracts:
    path: ../module_contracts

  # INVALID - these would break boundary rules:
  # finance_module:
  #   path: ../finance_module
```

## 6. Shared Kernel Decision

**Option A (Recommended): Keep core_module + add module_contracts**

| Factor | Option A (Keep + Add) | Option B (Split core_api/core_impl) |
|--------|----------------------|-------------------------------------|
| Migration cost | Low | High |
| Risk | Low | Medium |
| Time to implement | Days | Weeks |
| Module isolation | Good | Better |
| Future MFE readiness | Good | Better |
| Immediate benefit | High | Low |

**Recommendation**: Start with Option A.

When you eventually need Dynamic Feature Modules or Runtime Plugin Loading, then split into core_api/core_impl.

## 7. Event Bus Implementation (lightweight)

```dart
// In module_contracts
class ModuleEventBus {
  static final ModuleEventBus _instance = ModuleEventBus._();
  factory ModuleEventBus() => _instance;
  ModuleEventBus._();

  final _controller = StreamController<ModuleEvent>.broadcast();

  void publish(ModuleEvent event) {
    _controller.add(event);
  }

  Stream<T> on<T extends ModuleEvent>() {
    return _controller.stream.whereType<T>();
  }

  void dispose() => _controller.close();
}

// Base event
abstract class ModuleEvent {
  final DateTime timestamp = DateTime.now();
}
```

Usage example:

```dart
// In ResidentModule.initialize():
ModuleEventBus().on<ResidentCreated>().listen((event) {
  // Log, notify, or trigger other actions
});

// When resident is created:
ModuleEventBus().publish(ResidentCreated(
  residentId: resident.id,
  name: resident.name,
));
```
