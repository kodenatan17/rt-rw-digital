# RT-RW Digital Architecture

## MFE-Ready Modular Monolith

This document set describes the target architecture for evolving the RT-RW Digital platform into an MFE-Ready Modular Monolith.

## Index

| Document | Description | 
|----------|-------------|
| [01-architecture-review.md](01-architecture-review.md) | Review of current architecture with strengths and gaps |
| [02-gap-analysis.md](02-gap-analysis.md) | Current state vs target state mapping |
| [03-recommended-architecture.md](03-recommended-architecture.md) | Recommended architecture with package structure |
| [04-feature-module-contract.md](04-feature-module-contract.md) | FeatureModule interface and supporting types |
| [05-module-registry.md](05-module-registry.md) | ModuleRegistry design and bootstrap integration |
| [06-manifest-specification.md](06-manifest-specification.md) | ModuleManifest schema with YAML representation |
| [07-route-self-registration.md](07-route-self-registration.md) | Route ownership and registration flow |
| [08-feature-flag-strategy.md](08-feature-flag-strategy.md) | Feature flag service and backend integration |
| [09-version-compatibility.md](09-version-compatibility.md) | Version compatibility checking strategy |
| [10-module-boundary-strategy.md](10-module-boundary-strategy.md) | Module boundary rules and communication patterns |
| [11-ai-agent-module-template.md](11-ai-agent-module-template.md) | AI-agent template for generating feature modules |
| [12-example-implementation.md](12-example-implementation.md) | Example migration for resident_module |
| [13-migration-roadmap.md](13-migration-roadmap.md) | Phase 1-4 migration plan with tasks and verification |
| [14-risk-assessment.md](14-risk-assessment.md) | Risk matrix with mitigation strategies |
| [15-rollback-strategy.md](15-rollback-strategy.md) | Per-phase rollback procedures |
| [16-mermaid-diagrams.md](16-mermaid-diagrams.md) | Architecture diagrams: dependencies, bootstrap, lifecycle, routes |
| [17-architecture-classification.md](17-architecture-classification.md) | Final classification and justification |

## Quick Start

```
Phase 1: Create module_contracts package + ModuleRegistry
Phase 2: Migrate resident_module to FeatureModule contract
Phase 3: Connect feature flags to backend + version compatibility
Phase 4: Enforce boundaries + AI-agent readiness
```

## Key Principles

1. **Keep it working** - Android and iOS must continue normally
2. **Incremental** - Each phase is independently valuable
3. **No over-engineering** - Future MFE patterns are evaluated but not implemented
4. **Preserve existing** - Clean Architecture, DI, CI/CD stay unchanged
5. **AI-agent friendly** - Self-describing modules with standardized templates
