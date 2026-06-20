# Rollback Strategy

## 1. Rollback Layers

```
Layer 4: AI templates & boundaries ──── No rollback needed (additive)
Layer 3: Feature flags + compatibility ── Can disable server-side
Layer 2: resident_module migration ────── Can revert to old module
Layer 1: contracts + registry ─────────── Can remove if unused
```

## 2. Per-Phase Rollback

### Phase 1 (Contracts + Registry)
**Rollback difficulty**: Easy
**Action**: 
- `module_contracts` package is not referenced by any production code
- `ModuleRegistry` is instantiated but not wired to GoRouter yet
- Simply stop using them
- No user impact

### Phase 2 (resident_module Migration)
**Rollback difficulty**: Medium
**Action**: 
- Keep old `main.dart` as `main_old.dart` throughout Phase 2
- Rollback by reverting main.dart to use old boot sequence
- Optionally use feature flag `app.use_new_architecture=false` to switch
- No data migration needed (same module, same data)

```dart
// main.dart - Rollback switch
void main() async {
  if (await _useNewArchitecture()) {
    await _newBootstrap();
  } else {
    await _oldBootstrap();
  }
}
```

### Phase 3 (Feature Flags + Compatibility)
**Rollback difficulty**: Easy
**Action**:
- Disable feature flag API endpoint → app uses cached/local flags
- Set version check mode to "disabled" via remote config
- Remove forced update UI → app works as before
- No code revert needed

### Phase 4 (Boundaries + AI)
**Rollback difficulty**: Trivial
**Action**:
- Event bus is additive - not used by critical paths
- Module template is documentation - no production code
- Boundary rules are convention - no enforcement mechanism to break
- Simply stop using new patterns

## 3. Git Rollback Procedure

```bash
# Phase 1 rollback
git revert <phase1-commit-hash>
git push

# Phase 2 rollback (if flag-based switch not possible)
git checkout <pre-phase2-tag> -- rt-rw-digital/lib/main.dart
git checkout <pre-phase2-tag> -- resident_module/lib/
git commit -m "rollback: Phase 2 migration" 
```

## 4. Feature Flag Kill Switch

```dart
// Emergency kill switch for new architecture
class KillSwitches {
  static bool get useNewArchitecture {
    // 1. Check remote config
    // 2. Fall back to local storage
    // 3. Default to true
    return RemoteConfig().getBool('kill_new_arch') ?? true;
  }
}

void main() {
  if (KillSwitches.useNewArchitecture) {
    runWithRegistry();
  } else {
    runLegacy();
  }
}
```

## 5. Rollback Testing

Before each phase release:
1. Document exact rollback steps
2. Test rollback in staging
3. Verify no data loss after rollback
4. Verify no user-visible disruption
5. Timebox rollback: < 30 minutes

## 6. Rollback Communication

| Audience | Message | Channel |
|----------|---------|---------|
| Team | "Rolling back Phase X due to [reason]" | Slack #engineering |
| QA | "Rollback in progress. Test old behavior." | QA channel |
| Product | "Release held. Rolling back. ETA for fix: [time]" | Product sync |
| Users | No communication needed (no user-facing change) | N/A |
