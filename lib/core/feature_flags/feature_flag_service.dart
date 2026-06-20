import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:core_module/core_module.dart';

/// Event emitted when a feature flag changes.
class FlagChange {
  final String key;
  final bool value;

  const FlagChange({required this.key, required this.value});
}

/// Source for fetching feature flags remotely.
abstract class FeatureFlagRemoteSource {
  Future<Map<String, bool>> fetchFlags();
}

/// Local cache for feature flags.
abstract class FeatureFlagLocalCache {
  Future<void> cache(Map<String, bool> flags);
  Future<Map<String, bool>?> getCached();
  Future<void> clear();
}

/// Controls module and feature visibility.
///
/// # Offline-First Resolution Order
/// 1. Remote flags (GrowthBook API) — highest priority
/// 2. Local cached flags — used when remote unavailable
/// 3. Module manifest defaults — fallback
///
/// # Non-Blocking Guarantee
/// - [loadCached] reads cache instantly, never throws.
/// - [refreshRemote] is safe to call at any time (background).
/// - GrowthBook unavailability NEVER blocks app startup.
class FeatureFlagService implements FeatureFlagRepository {
  final FeatureFlagRemoteSource? remoteSource;
  final FeatureFlagLocalCache? localCache;

  Map<String, bool> _remoteFlags = {};
  final Map<String, bool> _localOverrides = {};
  bool _loaded = false;

  final _changeController = StreamController<FlagChange>.broadcast();

  FeatureFlagService({
    this.remoteSource,
    this.localCache,
  });

  /// Stream of flag changes (for reactive UI).
  Stream<FlagChange> get onFlagChanged => _changeController.stream;

  /// Whether cached flags have been loaded at least once.
  bool get isLoaded => _loaded;

  // ── FeatureFlagRepository implementation ──────────

  @override
  Map<String, bool> resolveFlags() =>
      {..._remoteFlags, ..._localOverrides};

  @override
  bool isEnabled(String flagName) {
    // 1. Remote/cached flags (highest priority)
    if (_remoteFlags.containsKey(flagName)) {
      return _remoteFlags[flagName]!;
    }
    // 2. Local overrides (debug only)
    if (_localOverrides.containsKey(flagName)) {
      return _localOverrides[flagName]!;
    }
    // 3. No override — caller falls back to manifest default.
    return true;
  }

  @override
  Future<void> loadCached() async {
    if (localCache != null) {
      try {
        final cached = await localCache!.getCached();
        if (cached != null) {
          _remoteFlags = cached;
        }
      } catch (_) {
        // Cache read failure is non-fatal.
      }
    }
    _loaded = true;
    debugPrint('FeatureFlagService: Loaded ${_remoteFlags.length} cached flag(s)');
  }

  @override
  Future<bool> refreshRemote() async {
    if (remoteSource == null) return false;

    try {
      final remote = await remoteSource!.fetchFlags();
      _remoteFlags = remote;
      // Persist to cache for next cold start
      if (localCache != null) {
        await localCache!.cache(remote);
      }
      debugPrint('FeatureFlagService: Refreshed ${remote.length} flag(s)');
      return true;
    } catch (e) {
      debugPrint('FeatureFlagService: Remote refresh failed — using cached: $e');
      return false;
    }
  }

  @override
  Future<void> saveFlags(Map<String, bool> flags) async {
    _remoteFlags = flags;
    if (localCache != null) {
      await localCache!.cache(flags);
    }
  }

  // ── Module Helpers ────────────────────────────────

  /// Check if a module is enabled (remote → cache → true default).
  bool isModuleEnabled(String moduleName) {
    return isEnabled('$moduleName.enabled');
  }

  /// Check if a module's menu should be visible.
  bool isModuleVisible(String moduleName) {
    if (!isModuleEnabled(moduleName)) return false;
    return isEnabled('$moduleName.visible');
  }

  /// All known flags (remote + local overrides).
  Map<String, bool> get allFlags => {..._remoteFlags, ..._localOverrides};

  // ── Local Overrides (Debug Only) ──────────────────

  void setOverride(String flagName, bool value) {
    _localOverrides[flagName] = value;
    _changeController.add(FlagChange(key: flagName, value: value));
  }

  void removeOverride(String flagName) {
    _localOverrides.remove(flagName);
  }

  void clearOverrides() {
    _localOverrides.clear();
  }

  /// Dispose the service.
  void dispose() {
    _changeController.close();
  }
}
