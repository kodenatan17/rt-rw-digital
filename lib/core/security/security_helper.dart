import 'package:flutter/foundation.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

// ══════════════════════════════════════════════════════════════════════
//  Security Check Result
// ══════════════════════════════════════════════════════════════════════

/// Immutable snapshot of the device security state.
///
/// [isCompromised] is `true` when [isJailbroken] is `true` (iOS jailbreak
/// or Android root). [isDeveloperModeEnabled] is tracked separately for
/// logging/analytics but does NOT block app access — developer mode alone
/// is a legitimate configuration on Android (USB debugging, accessibility
/// tools) and should not gate app usage.
@immutable
class SecurityCheckResult {
  final bool isJailbroken;
  final bool isDeveloperModeEnabled;
  final bool isCompromised;

  const SecurityCheckResult({
    required this.isJailbroken,
    required this.isDeveloperModeEnabled,
  }) : isCompromised = isJailbroken;

  /// Safe default — used when detection throws an unexpected error.
  const SecurityCheckResult.safe()
      : isJailbroken = false,
        isDeveloperModeEnabled = false,
        isCompromised = false;

  @override
  String toString() =>
      'SecurityCheckResult(jailbroken: $isJailbroken, '
      'devMode: $isDeveloperModeEnabled, '
      'compromised: $isCompromised)';
}

// ══════════════════════════════════════════════════════════════════════
//  SecurityHelper
// ══════════════════════════════════════════════════════════════════════

/// Handles device integrity validation (jailbreak / root detection).
///
/// Call [checkDevice] once, immediately after
/// [WidgetsFlutterBinding.ensureInitialized], before any other
/// initialisation so compromised devices are blocked as early as possible.
///
/// # Enforcement policy
/// Only [isJailbroken] blocks the app in release builds. Developer mode
/// is logged but does NOT prevent access (many legitimate Android
/// workflows require USB debugging).
///
/// Security is only enforced in **release** builds ([enforceSecurity]).
/// Debug / profile builds always pass so that the team can run on
/// physical devices without interference.
///
/// # Failure safety
/// All platform-channel exceptions are caught. On failure the helper
/// returns [SecurityCheckResult.safe] so a transient plugin error never
/// prevents a legitimate user from opening the app.
///
/// Usage:
/// ```dart
/// final result = await SecurityHelper.checkDevice();
/// if (SecurityHelper.enforceSecurity && result.isCompromised) {
///   runApp(const SecurityBlockedApp());
///   return;
/// }
/// ```
class SecurityHelper {
  SecurityHelper._();

  // ── Public API ────────────────────────────────────

  /// Whether security enforcement is active.
  ///
  /// `true` only in release builds; `false` in debug / profile so
  /// developers can run freely on physical devices.
  static bool get enforceSecurity => kReleaseMode;

  /// Check device integrity via [FlutterJailbreakDetection].
  ///
  /// Checks:
  /// - [FlutterJailbreakDetection.jailbroken] — iOS jailbreak / Android root
  /// - [FlutterJailbreakDetection.developerMode] — ADB / developer options
  ///
  /// Developer mode is returned but does NOT set [SecurityCheckResult.isCompromised].
  ///
  /// Never throws — returns [SecurityCheckResult.safe] on any error.
  static Future<SecurityCheckResult> checkDevice() async {
    try {
      final isJailbroken = await FlutterJailbreakDetection.jailbroken;
      final isDeveloperMode = await FlutterJailbreakDetection.developerMode;

      final result = SecurityCheckResult(
        isJailbroken: isJailbroken,
        isDeveloperModeEnabled: isDeveloperMode,
      );

      if (result.isCompromised) {
        debugPrint('SecurityHelper: ⚠ Device JAILBROKEN/ROOTED — $result');
      } else {
        debugPrint('SecurityHelper: Device security check PASSED. $result');
      }

      return result;
    } catch (e, stack) {
      // Plugin unavailable (simulator, unit-test host, etc.) — fail open.
      debugPrint('SecurityHelper: Detection error — assuming safe: $e');
      debugPrint('$stack');
      return const SecurityCheckResult.safe();
    }
  }
}
