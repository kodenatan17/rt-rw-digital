# Module Manifest Specification

## 1. Purpose

Every module exposes a `ModuleManifest` - a self-describing metadata object.

AI agents, developers, and the shell can read a module's manifest to understand it without reading implementation code.

## 2. Manifest Schema

```dart
class ModuleManifest {
  // ── Identity ─────────────────────────────────────
  final String name;              // "resident"
  final String displayName;       // "Resident Management"
  final ModuleVersion version;    // 1.0.0

  // ── Description ──────────────────────────────────
  final String description;       // "Manage resident profiles..."
  final String? author;           // "Team A"
  final String? repository;       // "https://github.com/..."

  // ── Dependencies ─────────────────────────────────
  final List<ModuleDependency> dependencies;

  // ── Compatibility ────────────────────────────────
  final ModuleVersion minShellVersion;    // Minimum shell version
  final ModuleVersion? recommendedShellVersion; // Recommended shell

  // ── Routes ──────────────────────────────────────
  final List<RouteDefinition> routeDefinitions;

  // ── Permissions ─────────────────────────────────
  final List<ModulePermission> permissions;

  // ── Feature Flags ───────────────────────────────
  final Map<String, bool> featureFlags;  // Default flag values

  // ── Capabilities ────────────────────────────────
  final List<String> provides;    // What this module provides (e.g. "resident.crud")

  // ── Build Metadata ──────────────────────────────
  final String? buildNumber;
  final String? environment;      // "dev", "staging", "production"
}

class ModuleDependency {
  final String moduleName;        // "core_module"
  final ModuleVersion minVersion; // Minimum compatible version
  final bool optional;            // Whether dependency is optional
}

class RouteDefinition {
  final String path;              // "/resident"
  final String name;              // "resident.list"
  final String description;       // "List all residents"
  final bool requiresAuth;        // true
  final List<String> requiredPermissions;
}
```

## 3. YAML Representation

For file-based storage/exchange:

```yaml
name: resident
display_name: "Resident Management"
version: 1.0.0
description: "Manage resident profiles, phone numbers, and email addresses"
author: "Team A"
repository: "https://github.com/org/rt-rw"

dependencies:
  - module: core_module
    min_version: 1.0.0
    optional: false
  - module: notification
    min_version: 0.5.0
    optional: true

compatibility:
  min_shell_version: 1.0.0
  recommended_shell_version: 1.2.0

routes:
  - path: "/resident"
    name: "resident.list"
    description: "Resident list page"
    requires_auth: true
  - path: "/resident/:id"
    name: "resident.detail"
    description: "Resident detail page"
    requires_auth: true
  - path: "/resident/create"
    name: "resident.create"
    description: "Create new resident"
    requires_auth: true
    permissions: ["resident.write"]

permissions:
  - name: "resident.read"
    description: "View resident data"
  - name: "resident.write"
    description: "Create and update residents"

feature_flags:
  resident.enabled: true
  resident.export: false
  resident.advanced_search: false

provides:
  - "resident.crud"
  - "resident.search"
```

## 4. AI-Agent Usage

An AI agent can read this manifest and:

1. **Generate routes**: Knows all route paths and names
2. **Generate APIs**: Knows what the module provides
3. **Generate permissions**: Knows required permission model
4. **Generate tests**: Knows dependencies and compatibility
5. **Generate documentation**: Has description, routes, permissions
6. **Generate feature widgets**: Knows feature flags and what's available
7. **Generate navigation**: Knows how to link to this module
