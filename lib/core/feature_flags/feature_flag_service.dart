import 'dart:async';

import 'package:flutter/foundation.dart';

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

/// Controls module and feature visibility remotely.
///
/// Resolution order:
/// 1. Remote flags (from API) — highest priority
/// 2. Local overrides (debug settings) — debug only
/// 3. Default values (from module manifests) — fallback
class FeatureFlagService {
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

  /// Stream of flag changes.
  Stream<FlagChange> get onFlagChanged => _changeController.stream;

  /// Whether flags have been loaded.
  bool get isLoaded => _loaded;

  /// Load flags from cache then remote.
  Future<void> load() async {
    // 1. Load from cache first (instant)
    if (localCache != null) {
      final cached = await localCache!.getCached();
      if (cached != null) {
        _remoteFlags = cached;
      }
    }

    // 2. Try remote (may fail — use cached/default)
    if (remoteSource != null) {
      try {
        final remote = await remoteSource!.fetchFlags();
        _remoteFlags = remote;
        // Update cache
        if (localCache != null) {
          await localCache!.cache(remote);
        }
      } catch (e) {
        debugPrint('FeatureFlagService: Remote fetch failed, using cached: $e');
      }
    }

    _loaded = true;
    debugPrint('FeatureFlagService: Loaded ${_remoteFlags.length} flag(s)');
  }

  /// Refresh flags from remote.
  Future<void> refresh() async {
    if (remoteSource == null) return;

    try {
      final remote = await remoteSource!.fetchFlags();
      _remoteFlags = remote;
      if (localCache != null) {
        await localCache!.cache(remote);
      }
      debugPrint('FeatureFlagService: Refreshed ${remote.length} flag(s)');
    } catch (e) {
      debugPrint('FeatureFlagService: Refresh failed: $e');
    }
  }

  // ── Flag Resolution ───────────────────────────────

  /// Check if a specific feature flag is enabled.
  bool isEnabled(String flagName) {
    // 1. Remote flags (highest priority)
    if (_remoteFlags.containsKey(flagName)) {
      return _remoteFlags[flagName]!;
    }

    // 2. Local overrides (debug only)
    if (_localOverrides.containsKey(flagName)) {
      return _localOverrides[flagName]!;
    }

    // 3. No default — assume enabled
    return true;
  }

  /// Check if a module is enabled.
  bool isModuleEnabled(String moduleName) {
    return isEnabled('$moduleName.enabled');
  }

  /// Check if a module's menu should be visible.
  bool isModuleVisible(String moduleName) {
    if (!isModuleEnabled(moduleName)) return false;
    return isEnabled('$moduleName.visible');
  }

  /// Get all flags for a module.
  Map<String, bool> getModuleFlags(String moduleName) {
    final result = <String, bool>{};
    for (final entry in _remoteFlags.entries) {
      if (entry.key.startsWith('$moduleName.')) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// All known flags (remote + local overrides).
  Map<String, bool> get allFlags => {..._remoteFlags, ..._localOverrides};

  // ── Local Overrides (Debug Only) ──────────────────

  /// Set a local override (debug builds only).
  void setOverride(String flagName, bool value) {
    _localOverrides[flagName] = value;
    _changeController.add(FlagChange(key: flagName, value: value));
  }

  /// Remove a local override.
  void removeOverride(String flagName) {
    _localOverrides.remove(flagName);
  }

  /// Clear all overrides.
  void clearOverrides() {
    _localOverrides.clear();
  }

  /// Dispose the service.
  void dispose() {
    _changeController.close();
  }
}
