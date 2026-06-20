import 'package:flutter/foundation.dart';
import 'package:growthbook_sdk_flutter/growthbook_sdk_flutter.dart';

import '../env/env_config.dart';
import 'feature_flag_service.dart';
import 'growthbook_feature_flag_source.dart';

/// Encapsulates GrowthBook SDK lifecycle.
///
/// Responsibilities:
/// - Initialize GrowthBook SDK with credentials from [EnvConfig]
/// - Create [GrowthBookFeatureFlagSource] from known flag keys
/// - Update user attributes (e.g. after login)
/// - Dispose SDK when no longer needed
///
/// Usage:
/// ```dart
/// final service = GrowthBookService();
/// await service.initialize(flagKeys: ['resident.enabled']);
/// final source = service.createSource();
/// ```
class GrowthBookService {
  GrowthBookSDK? _sdk;
  List<String>? _flagKeys;

  /// Whether GrowthBook SDK has been initialized.
  bool get isInitialized => _sdk != null;

  /// Initialize GrowthBook SDK with credentials from [EnvConfig].
  ///
  /// Returns `true` on success, `false` if API key is missing or init fails.
  /// Failure is non-blocking — flags fall back to manifest defaults.
  Future<bool> initialize({
    required List<String> flagKeys,
    Map<String, dynamic>? attributes,
  }) async {
    final apiKey = EnvConfig.growthBookApiKey;
    if (apiKey.isEmpty) {
      debugPrint('GrowthBookService: GROWTHBOOK_API_KEY not set — using manifest defaults.');
      return false;
    }

    _flagKeys = flagKeys;

    try {
      _sdk = await GBSDKBuilderApp(
        apiKey: apiKey,
        hostURL: EnvConfig.growthBookHostUrl,
        attributes: attributes ?? _defaultAttributes,
        growthBookTrackingCallBack: _onTrack,
      ).initialize();

      debugPrint('GrowthBookService: SDK initialized successfully.');
      return true;
    } catch (e) {
      debugPrint('GrowthBookService: Init failed — fallback to defaults: $e');
      return false;
    }
  }

  /// Create a [GrowthBookFeatureFlagSource] from initialized SDK.
  ///
  /// Returns `null` if SDK is not initialized.
  FeatureFlagRemoteSource? createSource() {
    if (_sdk == null || _flagKeys == null) return null;
    return GrowthBookFeatureFlagSource(
      sdk: _sdk!,
      flagKeys: _flagKeys!,
    );
  }

  /// Update user attributes after login or attribute change.
  void updateAttributes(Map<String, dynamic> attributes) {
    _sdk?.setAttributes(attributes);
    debugPrint('GrowthBookService: Attributes updated.');
  }

  /// Dispose SDK resources.
  void dispose() {
    _sdk = null;
    _flagKeys = null;
  }

  // ── Private ──────────────────────────────────────────

  Map<String, dynamic> get _defaultAttributes => {
        'id': 'anonymous',
        'environment': kReleaseMode ? 'production' : 'development',
      };

  void _onTrack(GBTrackData trackData) {
    debugPrint(
      'GrowthBook: Experiment "${trackData.experiment.key}"'
      ' → variation ${trackData.experimentResult.variationID}',
    );
  }
}
