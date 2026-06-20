import 'package:growthbook_sdk_flutter/growthbook_sdk_flutter.dart';

import 'feature_flag_service.dart';

/// Implements [FeatureFlagRemoteSource] using GrowthBook SDK.
///
/// Evaluates known flag keys via GrowthBook's local evaluation engine.
/// Flags are cached by GrowthBook with TTL + background sync.
///
/// Usage:
/// ```dart
/// final gbSDK = await GBSDKBuilderApp(
///   apiKey: 'sdk-xxx',
///   hostURL: 'https://cdn.growthbook.io',
///   attributes: {'id': 'user_123'},
/// ).initialize();
///
/// final source = GrowthBookFeatureFlagSource(
///   sdk: gbSDK,
///   flagKeys: ['resident.enabled', 'resident.visible'],
/// );
/// ```
class GrowthBookFeatureFlagSource implements FeatureFlagRemoteSource {
  final GrowthBookSDK _sdk;
  final List<String> _flagKeys;

  GrowthBookFeatureFlagSource({
    required GrowthBookSDK sdk,
    required List<String> flagKeys,
  })  : _sdk = sdk,
        _flagKeys = flagKeys;

  @override
  Future<Map<String, bool>> fetchFlags() async {
    final flags = <String, bool>{};
    for (final key in _flagKeys) {
      final feature = _sdk.feature(key);
      flags[key] = feature.on;
    }
    return flags;
  }
}
