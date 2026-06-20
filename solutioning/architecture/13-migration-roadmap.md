# Migration Roadmap

## Phase 1: Foundation (Week 1-2)

**Goal**: Create contracts package, define FeatureModule interface, implement ModuleRegistry.

### Tasks

| Task | Owner | Effort | Risk |
|------|-------|--------|------|
| Create `module_contracts` package | Backend/Shared | 1 day | Low |
| Define `FeatureModule` abstract class | Backend/Shared | 0.5 day | Low |
| Define `ModuleManifest` model | Backend/Shared | 0.5 day | Low |
| Define `ModuleVersion` + compatibility | Backend/Shared | 0.5 day | Low |
| Create `ModuleRegistry` class | Shell | 1 day | Low |
| Create `FeatureFlagService` interface | Backend/Shared | 0.5 day | Low |
| Create empty page stubs for resident_module | Module A | 1 day | Low |
| Set up CI to build contracts package | DevOps | 0.5 day | Low |

### Deliverables
- [ ] `module_contracts/` package with FeatureModule, ModuleManifest, ModuleVersion
- [ ] `ModuleRegistry` in shell app
- [ ] `FeatureFlagService` interface
- [ ] Module can be registered (even if no UI yet)
- [ ] Unit tests for contracts + registry

### Verification
```dart
final registry = ModuleRegistry();
final module = TestModule();
registry.register(module);
expect(registry.isRegistered('test'), true);
expect(registry.getModule('test'), module);
```

### Rollback
- contracts package is additive - no existing code changes
- ModuleRegistry is new - not yet used by main.dart
- Safe to revert at any point

---

## Phase 2: Core Migration (Week 3-4)

**Goal**: Migrate resident_module to FeatureModule contract. Update shell to use registry.

### Tasks

| Task | Owner | Effort | Risk |
|------|-------|--------|------|
| Add `module_contracts` dep to resident_module | Module A | 0.5 day | Low |
| Create `ResidentModule` implementing FeatureModule | Module A | 1 day | Low |
| Create `manifest.dart` with module metadata | Module A | 0.5 day | Low |
| Create `resident_routes.dart` with route definitions | Module A | 1 day | Medium |
| Create basic UI pages (list, detail, create) | Module A | 2 days | Medium |
| Update `main.dart` to use ModuleRegistry | Shell | 1 day | Medium |
| Update `app_injection.dart` to use module DI | Shell | 0.5 day | Low |
| Implement `GoRouter` with module route aggregation | Shell | 1 day | Medium |
| Implement feature flag local override (debug) | Shell | 0.5 day | Low |
| Retrofit existing resident features into new pattern | Module A | 2 days | Medium |

### Deliverables
- [ ] resident_module fully implements FeatureModule
- [ ] Shell uses ModuleRegistry for bootstrap
- [ ] Routes are module-owned
- [ ] Feature flags control module visibility (local)
- [ ] Existing resident functionality preserved
- [ ] Existing tests pass; new tests added

### Verification
```dart
// App boots with registry
final registry = ModuleRegistry();
registry.register(ResidentModule());
await registry.initializeAll();

// Routes are available
final routes = registry.allRoutes;
expect(routes.length, greaterThan(0));

// Module can be disabled
registry.disable('resident');
expect(registry.isEnabled('resident'), false);
// Routes excluded from registry.allRoutes
```

### Rollback
- Keep old main.dart as backup
- If registry fails, revert to direct import
- Feature flags are local-only in this phase
- Routes can be conditionally toggled

---

## Phase 3: Feature Flags & Compatibility (Week 5-6)

**Goal**: Connect feature flags to backend. Implement version compatibility.

### Tasks

| Task | Owner | Effort | Risk |
|------|-------|--------|------|
| Create `FeatureFlagRemoteSource` API client | Backend | 1 day | Low |
| Create `FeatureFlagLocalCache` (Hive) | Module A | 0.5 day | Low |
| Implement `FeatureFlagService` with remote/local merge | Shell | 1 day | Medium |
| Create `VersionCompatibility` checker | Shell | 1 day | Low |
| Implement bootstrap version check | Shell | 0.5 day | Low |
| Create forced-update UI | Shell | 1 day | Low |
| Add feature flag debug screen | Shell | 0.5 day | Low |
| Backend: Feature flag API endpoint | Backend | 1 day | Low |
| Backend: Version config API endpoint | Backend | 1 day | Low |
| Integration test for flag flow | QA | 1 day | Medium |

### Deliverables
- [ ] Feature flags loaded from backend at startup
- [ ] Module enable/disable via backend
- [ ] Menu visibility controlled remotely
- [ ] Version compatibility checked at bootstrap
- [ ] Forced update UI for incompatible versions
- [ ] Feature flag debug screen

### Verification
```dart
// Backend disables finance module
await flagService.refresh();
expect(registry.isEnabled('finance'), false);

// Old shell with new module
final result = compatibility.checkModuleCompatibility(newModuleManifest);
expect(result.compatible, false);
```

### Rollback
- Feature flags have local cache fallback
- If API fails, use last known good state
- Version check can be disabled via flag
- All changes backward compatible

---

## Phase 4: Module Boundaries & AI Readiness (Week 7-8)

**Goal**: Enforce module boundary rules. Make architecture AI-agent ready.

### Tasks

| Task | Owner | Effort | Risk |
|------|-------|--------|------|
| Create `ModuleEventBus` in contracts | Shared | 0.5 day | Low |
| Create navigation route constants | Shared | 0.5 day | Low |
| Define module API contracts (abstract interfaces) | Shared | 2 days | Medium |
| Refactor any existing cross-module deps | All modules | 2 days | Medium |
| Create AI-agent module template | Shared | 1 day | Low |
| Create `module_manifest.yaml` generator | DevOps | 1 day | Low |
| Add contract tests for module boundaries | QA | 2 days | Medium |
| Document architecture for AI agents | Shared | 1 day | Low |
| Create new module from template (e.g., meeting_module) | PoC | 2 days | Medium |

### Deliverables
- [ ] No direct module-to-module imports
- [ ] Event bus operational
- [ ] Module API contracts defined
- [ ] AI-agent template validated
- [ ] New module generated from template
- [ ] Contract tests for boundaries
- [ ] Architecture documentation

### Verification
```dart
// Verify no illegal imports
// resident_module/pubspec.yaml does NOT reference finance_module

// Event bus works
ModuleEventBus().publish(ResidentCreated(residentId: '1', name: 'John'));

// AI template produces working module
// Generate meeting_module from template → register → routes work
```

### Rollback
- Event bus is additive - existing code unchanged
- Contract tests can be disabled temporarily
- Template is documentation - no production impact
- New module is optional

---

## Phase Progression Summary

```
Phase 1: Contracts + Registry ──────────────► Foundation layer
                                                    │
Phase 2: resident_module migration ────────────────► Core migration
                                                    │
Phase 3: Feature flags + Compatibility ────────────► Remote control
                                                    │
Phase 4: Boundaries + AI readiness ───────────────► MFE-ready
                                                    │
                                          MFE-Ready Modular Monolith
```

## Total Effort Estimate

| Phase | Duration | Engineers | Total Person-Days |
|-------|----------|-----------|-------------------|
| Phase 1 | 2 weeks | 2 | 10 |
| Phase 2 | 2 weeks | 2 | 14 |
| Phase 3 | 2 weeks | 2 | 12 |
| Phase 4 | 2 weeks | 2 | 12 |
| **Total** | **8 weeks** | **2** | **48 person-days** |

## Dependency Order

```
Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4
   │            │            │            │
   ▼            ▼            ▼            ▼
contracts   resident      feature      boundaries
registry     migration    flags         AI template
```

Phase 1 is prerequisite for all others.
Phase 2 can start as soon as Phase 1 is stable.
Phase 3 requires Phase 2 for integration testing.
Phase 4 can overlap with Phase 3.
