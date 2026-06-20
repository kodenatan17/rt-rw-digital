# Gap Analysis - Current State vs Target State

## Current State → Target State Mapping

| Capability | Current State | Target State | Delta |
|-----------|--------------|--------------|-------|
| **Module Identity** | No identity | `FeatureModule` contract with name, version | **Missing** |
| **Module Registration** | Manual import in main.dart | `ModuleRegistry.register()` at bootstrap | **Missing** |
| **Module Discovery** | None | Registry enumerates all registered modules | **Missing** |
| **Module Enable/Disable** | None | Feature flags control module visibility | **Missing** |
| **Route Ownership** | Empty routes/ directories | Modules provide `GoRouter` route configs | **Missing** |
| **Module Metadata** | None | `ModuleManifest` with description, permissions, deps | **Missing** |
| **Version Compatibility** | None | Shell + module version checking | **Missing** |
| **Module Initialization** | Manual `setupInjection()` | `initialize()` lifecycle hook | **Missing** |
| **Module Boundaries** | Direct deps via pubspec | Contracts, event bus, shared abstractions | **Partial** |
| **Feature Flags** | None | Backend-controlled enable/disable/hide | **Missing** |
| **DI Setup** | Manual orchestration in app_injection | Module owns its DI; registry calls init | **Partial** |
| **Shared Kernel** | Single `core_module` package | Keep core_module, add contracts gradually | **Adequate** |
| **Public API** | `public_api.dart` per module | Standardized API surface per contract | **Good** |
| **Clean Architecture** | Present but incomplete | Full domain/data/presentation per module | **Partial** |
| **Testing** | Minimal (1 test file) | Unit + integration + contract tests | **Missing** |
| **AI-Agent Readiness** | None | Template-driven, self-describing modules | **Missing** |
| **CI/CD** | Existing pipeline | Compatible with current CI/CD | **Good** |

## Priority Classification

### P1: Must Have (Phase 1-2)
- FeatureModule contract interface
- ModuleRegistry with discover/enable/disable
- ModuleManifest with metadata
- Route self-registration
- Feature flag integration
- Version compatibility strategy

### P2: Should Have (Phase 3)
- Module boundary rules & contracts
- Module testing strategy
- AI-agent friendly structure
- Inter-module communication (event bus)

### P3: Future Consideration (Phase 4+)
- core_api/core_impl split
- Deferred loading
- Dynamic Feature Modules
- Runtime plugin loading
- Mini App Architecture
