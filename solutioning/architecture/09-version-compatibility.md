# Version Compatibility Strategy

## 1. Purpose

Ensure shell and modules are compatible at build time and runtime.

## 2. Version Representation

```dart
class ModuleVersion implements Comparable<ModuleVersion> {
  final int major;
  final int minor;
  final int patch;

  const ModuleVersion(this.major, this.minor, this.patch);

  String get asString => '$major.$minor.$patch';

  /// Check if this version is compatible with a constraint.
  bool satisfies({required ModuleVersion min, ModuleVersion? max}) {
    if (this < min) return false;
    if (max != null && this > max) return false;
    return true;
  }

  @override
  int compareTo(ModuleVersion other) {
    final majorCmp = major.compareTo(other.major);
    if (majorCmp != 0) return majorCmp;
    final minorCmp = minor.compareTo(other.minor);
    if (minorCmp != 0) return minorCmp;
    return patch.compareTo(other.patch);
  }

  bool operator >=(ModuleVersion other) => compareTo(other) >= 0;
  bool operator <=(ModuleVersion other) => compareTo(other) <= 0;
  bool operator >(ModuleVersion other) => compareTo(other) > 0;
  bool operator <(ModuleVersion other) => compareTo(other) < 0;
}
```

## 3. Version Sources

| Source | Location | Example |
|--------|----------|---------|
| Shell version | pubspec.yaml of rt-rw-digital | `version: 1.0.0+1` |
| Module version | Manifest | `version: 1.0.0` |
| Min shell version | Manifest | `minShellVersion: 1.0.0` |
| Min module version | Shell configuration | `minModuleVersion: 1.0.0` |
| Remote min version | API response | `min_app_version: 1.2.0` |

## 4. Compatibility Checking

```dart
class VersionCompatibility {
  final ModuleVersion shellVersion;
  final Map<String, ModuleVersion> _moduleMinVersions = {};

  /// Check if a module is compatible with current shell.
  CompatibilityResult checkModuleCompatibility(ModuleManifest manifest) {
    // Module requires minimum shell version
    if (shellVersion < manifest.minShellVersion) {
      return CompatibilityResult(
        compatible: false,
        reason: 'Module ${manifest.name} requires shell '
            '${manifest.minShellVersion.asString} but shell is '
            '${shellVersion.asString}',
        severity: CompatibilitySeverity.blocking,
      );
    }

    // Check recommended version
    if (manifest.recommendedShellVersion != null &&
        shellVersion < manifest.recommendedShellVersion!) {
      return CompatibilityResult(
        compatible: true,
        reason: 'Module ${manifest.name} recommends shell '
            '${manifest.recommendedShellVersion!.asString}',
        severity: CompatibilitySeverity.warning,
      );
    }

    return CompatibilityResult(
      compatible: true,
      reason: null,
      severity: CompatibilitySeverity.ok,
    );
  }

  /// Check all modules and return results.
  List<CompatibilityResult> checkAll(List<ModuleManifest> manifests) {
    return manifests.map(checkModuleCompatibility).toList();
  }
}

class CompatibilityResult {
  final bool compatible;
  final String? reason;
  final CompatibilitySeverity severity;

  const CompatibilityResult({
    required this.compatible,
    this.reason,
    required this.severity,
  });
}

enum CompatibilitySeverity { ok, warning, blocking }
```

## 5. Bootstrap Integration

```dart
Future<void> main() async {
  // ... setup ...

  final compatibility = VersionCompatibility(
    shellVersion: ModuleVersion(1, 0, 0),
  );

  // Check all modules
  final results = compatibility.checkAll(registry.allManifests);
  final blocked = results.where((r) => r.severity == CompatibilitySeverity.blocking);

  if (blocked.isNotEmpty) {
    // Show forced update screen
    runApp(ForcedUpdateApp(
      message: 'App update required',
      modules: blocked.map((r) => r.reason!).toList(),
    ));
    return;
  }

  // Show warnings but continue
  final warnings = results.where((r) => r.severity == CompatibilitySeverity.warning);
  if (warnings.isNotEmpty) {
    // Log or show non-blocking notification
  }

  // Continue bootstrap...
}
```

## 6. Remote Minimum Version

```dart
class RemoteVersionService {
  Future<Map<String, ModuleVersion>> fetchMinimumVersions() async {
    // GET /api/v1/app/versions
    // Returns: {
    //   "shell": { "min": "1.0.0", "recommended": "1.2.0" },
    //   "resident": { "min": "1.0.0" },
    //   "finance": { "min": "0.5.0" }
    // }
    final response = await dio.get('/app/versions');
    return _parseVersions(response.data);
  }
}
```

## 7. Version Enforcement Rules

| Scenario | Action |
|----------|--------|
| Module requires shell > current shell | Block module, show update prompt |
| Module recommends shell > current shell | Allow module, show non-blocking update suggestion |
| Shell requires module > current module | Block module, require module update |
| Version mismatch between modules | Warn but allow (modules are loosely coupled) |

## 8. Version Display

```dart
class AppVersionInfo extends StatelessWidget {
  final ModuleRegistry registry;

  @override
  Widget build(BuildContext context) {
    final modules = registry.allManifests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('App: ${_shellVersion}'),
        Text('Build: ${_buildNumber}'),
        ...modules.map((m) => Text('${m.name}: ${m.version.asString}')),
      ],
    );
  }
}
```

## 9. pubspec.yaml Version Source

Shell app version read from pubspec.yaml:

```dart
class ShellVersionReader {
  static ModuleVersion read() {
    // Read from PackageInfo or from pubspec.yaml
    return ModuleVersion(1, 0, 0);
  }
}
```
