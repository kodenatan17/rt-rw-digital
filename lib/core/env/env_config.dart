import 'package:envied/envied.dart';

part 'env_config.g.dart';

/// API credentials and environment configuration.
///
/// Values are read from `.env` file at build time via envied codegen.
/// Never commit `.env` or `env_config.g.dart` to version control.
///
/// Usage:
/// ```dart
/// final apiKey = EnvConfig.growthBookApiKey;
/// ```
@Envied(path: '.env', obfuscate: true)
abstract class EnvConfig {
  /// GrowthBook SDK API key for feature flag evaluation.
  @EnviedField(varName: 'GROWTHBOOK_API_KEY')
  static final String growthBookApiKey = _EnvConfig.growthBookApiKey;

  /// GrowthBook host URL (defaults to GrowthBook CDN).
  @EnviedField(varName: 'GROWTHBOOK_HOST_URL', defaultValue: 'https://cdn.growthbook.io')
  static final String growthBookHostUrl = _EnvConfig.growthBookHostUrl;
}
