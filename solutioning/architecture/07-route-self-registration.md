# Route Self-Registration

## 1. Problem

Current state: Routes either don't exist or would be defined in the shell app.

If the shell defines routes:
- Shell must know every module's routes
- Adding a module requires shell changes
- Route refactoring requires shell coordination
- Violates module independence

## 2. Solution: Module-Owned Routes

Each module provides its routes via the `FeatureModule.routes` getter.

The shell only:
1. Calls `registry.allRoutes` to get all routes
2. Passes them to `GoRouter`

The shell never:
- Defines module-specific route paths
- Imports module page widgets
- Knows about module route structure

## 3. Route Registration Flow

```
┌──────────┐    ┌──────────────┐    ┌──────────────┐
│  Module   │    │    Shell     │    │  ModuleReg.  │
└────┬─────┘    └──────┬───────┘    └──────┬───────┘
     │                 │                   │
     │  register()     │                   │
     │────────────────►│                   │
     │                 │                   │
     │                 │ register(module)  │
     │                 │──────────────────►│
     │                 │                   │
     │                 │ allRoutes         │
     │                 │◄─────────────────│
     │                 │                   │
     │                 │ Build GoRouter    │
     │                 │ with allRoutes    │
     │                 │                   │
```

## 4. Route Conflict Resolution

Since modules own their routes, conflicts are possible.

**Rule**: First-registered module wins.

```dart
class ModuleRegistry {
  List<RouteBase> getAllRoutes() {
    final routeMap = <String, RouteBase>{};
    final ordered = _modules.values.toList();

    for (final module in ordered) {
      for (final route in module.routes) {
        final path = _extractPath(route);
        if (!routeMap.containsKey(path)) {
          routeMap[path] = route;
        } else {
          // Log warning but don't override
          _logger.warn(
            'Route "$path" already registered by another module. Skipping.',
          );
        }
      }
    }
    return routeMap.values.toList();
  }
}
```

**Better approach**: Namespace routes by module name.

```dart
// Module routes are automatically under module name path
// resident_module routes:
//   /resident, /resident/:id, /resident/create

// finance_module routes:
//   /finance, /finance/iuran, /finance/kas

// This naturally avoids conflicts since module names are unique.
```

## 5. Navigation Between Modules

Modules navigate to other modules using string paths:

```dart
// In resident_module:
context.push('/finance/iuran');

// This does NOT create a direct dependency.
// The path is a convention, not an import.
```

**Better approach**: Use a navigation service with route name constants:

```dart
// Shared constants package (or in module_contracts)
class AppRoutes {
  static const resident = '/resident';
  static const residentDetail = '/resident/:id';

  static const finance = '/finance';
  static const financeIuran = '/finance/iuran';
}

// Usage:
context.push(AppRoutes.financeIuran);
```

## 6. Deep Linking Support

Module routes automatically support deep linking since they're GoRouter routes.

```dart
// Deep link: rt-rw://resident/123
// GoRouter resolves to ResidentDetailPage(id: '123')
```

## 7. Route Permissions

Routes that require specific permissions check them in redirect:

```dart
GoRoute(
  path: '/resident/create',
  name: 'resident.create',
  builder: (context, state) => const ResidentCreatePage(),
  redirect: (context, state) {
    if (!hasPermission('resident.write')) {
      return '/login';  // or show unauthorized
    }
    return null;
  },
);
```
