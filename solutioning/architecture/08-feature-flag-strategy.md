# Feature Flag Strategy

## 1. Purpose

Control module visibility and functionality remotely without app release.

## 2. Feature Flag Service

```dart
abstract class FeatureFlagService {
  /// Load all flags from remote source.
  Future<void> load();

  /// Check if a feature is enabled.
  bool isEnabled(String featureName);

  /// Check if a module's menu should be visible.
  bool isVisible(String moduleName);

  /// Get all flags for a module.
  Map<String, bool> getModuleFlags(String moduleName);

  /// Refresh flags from remote.
  Future<void> refresh();

  /// Listen for flag changes.
  Stream<FlagChange> get onFlagChanged;
}
```

## 3. Flag Categories

| Flag Pattern | Example | Effect |
|-------------|---------|--------|
| `{module}.enabled` | `resident.enabled` | Module fully enabled/disabled |
| `{module}.visible` | `resident.visible` | Module functional but menu hidden |
| `{module}.{feature}` | `resident.export` | Specific feature within module |
| `shell.{feature}` | `shell.dark_mode` | Shell-level feature |

## 4. Flag Resolution Order

```
1. Remote flag (from API) → highest priority
2. Local override (developer settings) → debug only
3. Default value (from module manifest) → fallback
```

```dart
bool isEnabled(String featureName) {
  // 1. Check remote flags first
  if (_remoteFlags.containsKey(featureName)) {
    return _remoteFlags[featureName]!;
  }

  // 2. Check local overrides (debug only)
  if (_localOverrides.containsKey(featureName)) {
    return _localOverrides[featureName]!;
  }

  // 3. Return default from manifest
  return _getDefaultFromManifest(featureName);
}
```

## 5. Remote Flag Source (API)

```dart
class ApiFeatureFlagSource implements FeatureFlagSource {
  @override
  Future<Map<String, bool>> fetchFlags() async {
    // GET /api/v1/feature-flags
    // Returns: { "resident.enabled": true, "finance.enabled": false }
    final response = await dio.get('/feature-flags');
    return Map<String, bool>.from(response.data['flags']);
  }
}
```

## 6. Local Cache

```dart
class LocalFeatureFlagCache implements FeatureFlagCache {
  Future<void> cache(Map<String, bool> flags);
  Future<Map<String, bool>?> getCached();
  Future<void> clear();
}
```

Flags cached locally so app works offline.
Cache refreshed on app start and periodically.

## 7. Module Integration

Module checks flags before exposing functionality:

```dart
class ResidentModule implements FeatureModule {
  @override
  bool isAvailable(FeatureFlagService flags) {
    return flags.isEnabled('resident.enabled');
  }

  @override
  List<RouteBase> get routes {
    // Routes only include feature-gated content
    final routes = <RouteBase>[..._coreRoutes];

    if (_featureFlags?.isEnabled('resident.export') ?? false) {
      routes.add(
        GoRoute(
          path: 'export',
          builder: (context, state) => const ResidentExportPage(),
        ),
      );
    }

    return routes;
  }
}
```

## 8. Backend API Contract

```
GET /api/v1/feature-flags

Response:
{
  "flags": {
    "resident.enabled": true,
    "resident.visible": true,
    "resident.export": false,
    "finance.enabled": false,
    "finance.visible": false
  },
  "app_version": "1.0.0",
  "config_version": 42
}
```

## 9. Developer Override Screen

For testing (debug builds only):

```dart
class FeatureFlagDebugScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feature Flags')),
      body: ListView(
        children: flagService.allFlags.entries.map((entry) {
          return SwitchListTile(
            title: Text(entry.key),
            value: entry.value,
            onChanged: (value) {
              flagService.setOverride(entry.key, value);
            },
          );
        }).toList(),
      ),
    );
  }
}
```

## 10. Implementation in ModuleRegistry

```dart
class ModuleRegistry {
  void setFeatureFlagService(FeatureFlagService service) {
    _featureFlagService = service;

    // Listen for flag changes
    service.onFlagChanged.listen((change) {
      if (change.moduleName != null) {
        final module = _modules[change.moduleName!];
        if (module != null && change.key == '${module.name}.enabled') {
          if (change.value) {
            _enableModule(module);
          } else {
            _disableModule(module);
          }
        }
      }
    });
  }

  bool isVisible(String moduleName) {
    final module = _modules[moduleName];
    if (module == null) return false;

    if (!isEnabled(moduleName)) return false;

    // Check visibility flag
    final visible = _featureFlagService?.isVisible(moduleName);
    return visible ?? true;
  }
}
```
