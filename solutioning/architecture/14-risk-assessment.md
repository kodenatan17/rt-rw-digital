# Risk Assessment

## 1. Risk Matrix

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|------------|
| R1 | Breaking existing module functionality during migration | Medium | High | Incremental migration, feature-flag gated, existing code unchanged until new path verified |
| R2 | ModuleRegistry becomes single point of failure | Low | High | Registry is in-memory, stateless, no external deps; if it fails, app fails at bootstrap (immediately visible) |
| R3 | Route conflicts between modules | Low | Medium | Namespace routes by module name; first-registered wins; logging for duplicates |
| R4 | Feature flag API unavailable at startup | Medium | Low | Local cache fallback; app works with last known good state; flags are not critical for core functionality |
| R5 | Version compatibility blocks legitimate users | Low | High | Server-controlled minimum versions; can roll back server-side; non-blocking warning option |
| R6 | Team learning curve for new patterns | Medium | Medium | Phase 1 is pure additive; documentation and templates provided; pair programming for Phase 2 |
| R7 | Over-engineering for future MFE | Medium | Medium | Strict scope control; only implement what's needed now; "Future Consideration" items explicitly deferred |
| R8 | AI template produces non-functional modules | Medium | Low | Template validated by generating a real module; CI tests verify generated output |
| R9 | Module boundary enforcement too strict | Low | Low | Boundaries are convention + pubspec enforcement; can be relaxed case-by-case |
| R10 | Increased build time from more packages | Low | Medium | Packages are local path dependencies; no network fetch; minimal impact on build time |

## 2. Risk Mitigation Details

### R1: Breaking existing functionality
```
Mitigation Strategy: Strangler Fig Pattern

Phase 2 approach:
1. Keep old main.dart in parallel
2. New registry-based bootstrap alongside old code
3. Feature flag gating: new code path controlled by 'app.new_architecture' flag
4. If flag fails → fall back to old bootstrap
5. Only remove old code after 2 weeks of stable new path
```

### R4: Feature flag API unavailable
```
Mitigation Strategy: Graceful Degradation

Startup flow:
1. Load flags from local cache (instant)
2. Try API call with timeout (5 seconds)
3. If API succeeds → update cache
4. If API fails → use cached values
5. If no cache → use manifest defaults
6. App continues regardless of flag state
```

### R5: Version compatibility blocks users
```
Mitigation Strategy: Flexible Enforcement

Compatibility modes:
- strict: Block incompatible modules (default for major mismatches)
- warning: Show alert but continue (minor/patch mismatches)
- disabled: Skip all checks (emergency override via remote config)

Backend can switch mode without app update.
```

## 3. Risk Monitoring

| Check | Frequency | Method |
|-------|-----------|--------|
| Module registration success | Every build | CI test |
| Feature flag sync | Every app start | Logged metric |
| Version compatibility | Every app start | Logged metric |
| Route conflict detection | Every build | CI check |
| Module boundary compliance | Every PR | CI check (pubspec analyzer) |

## 4. Contingency Plans

| Scenario | Plan |
|----------|------|
| ModuleRegistry bug blocks app | Revert to old main.dart (Phase 2 rollback) |
| Feature flag API is down long-term | App works with cached/default flags; no user-facing impact |
| Version check blocks users incorrectly | Server-side disable of version check; push hotfix |
| Route conflict breaks navigation | Revert problematic module; fix route namespacing |
| Migration taking too long | Extend Phase 2 timeline; defer Phase 3 until stable |
