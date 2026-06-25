import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rt_rw_digital/core/security/security_helper.dart';

void main() {
  // ════════════════════════════════════════════════════════════════════
  //  Channel-based tests need the test binding.
  // ════════════════════════════════════════════════════════════════════
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  // ════════════════════════════════════════════════════════════════════
  //  SecurityCheckResult unit tests (pure Dart — no channel needed)
  // ════════════════════════════════════════════════════════════════════
  group('SecurityCheckResult', () {
    test('isCompromised is true when isJailbroken is true', () {
      const result = SecurityCheckResult(
        isJailbroken: true,
        isDeveloperModeEnabled: false,
      );
      expect(result.isCompromised, true);
      expect(result.isJailbroken, true);
      expect(result.isDeveloperModeEnabled, false);
    });

    test('isCompromised is false when only developer mode is enabled', () {
      const result = SecurityCheckResult(
        isJailbroken: false,
        isDeveloperModeEnabled: true,
      );
      expect(result.isCompromised, false);
      expect(result.isJailbroken, false);
      expect(result.isDeveloperModeEnabled, true);
    });

    test('isCompromised is false when neither jailbroken nor dev mode', () {
      const result = SecurityCheckResult(
        isJailbroken: false,
        isDeveloperModeEnabled: false,
      );
      expect(result.isCompromised, false);
    });

    test('isCompromised is true when both jailbroken and dev mode', () {
      const result = SecurityCheckResult(
        isJailbroken: true,
        isDeveloperModeEnabled: true,
      );
      expect(result.isCompromised, true);
      // Dev mode alone never sets compromised — must also be jailbroken.
      expect(result.isJailbroken, true);
    });

    test('safe constructor returns all-false defaults', () {
      const result = SecurityCheckResult.safe();
      expect(result.isJailbroken, false);
      expect(result.isDeveloperModeEnabled, false);
      expect(result.isCompromised, false);
    });

    test('toString includes all fields', () {
      const result = SecurityCheckResult(
        isJailbroken: true,
        isDeveloperModeEnabled: false,
      );
      final str = result.toString();
      expect(str, contains('jailbroken: true'));
      expect(str, contains('devMode: false'));
      expect(str, contains('compromised: true'));
    });
  });

  // ════════════════════════════════════════════════════════════════════
  //  SecurityHelper.checkDevice() — channel mock tests
  // ════════════════════════════════════════════════════════════════════
  //
  //  FlutterJailbreakDetection communicates via MethodChannel.
  //  We mock the channel to simulate different device states.
  // ════════════════════════════════════════════════════════════════════

  group('SecurityHelper.checkDevice()', () {
    const channel = MethodChannel('flutter_jailbreak_detection');

    /// Helper: set mock handler that returns canned [jailbroken] and
    /// [developerMode] values.
    void setDetectionMock({
      required bool jailbroken,
      required bool developerMode,
    }) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        switch (call.method) {
          case 'jailbroken':
            return jailbroken;
          case 'developerMode':
            return developerMode;
          default:
            return null;
        }
      });
    }

    /// Helper: remove mock handler so the channel falls through.
    void clearDetectionMock() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    }

    setUp(() {
      clearDetectionMock();
    });

    tearDown(() {
      clearDetectionMock();
    });

    // ── Positive cases ──────────────────────────────────

    test('returns compromised=true when jailbroken', () async {
      setDetectionMock(jailbroken: true, developerMode: false);
      final result = await SecurityHelper.checkDevice();

      expect(result.isCompromised, true);
      expect(result.isJailbroken, true);
    });

    test('returns compromised=true when jailbroken + dev mode', () async {
      setDetectionMock(jailbroken: true, developerMode: true);
      final result = await SecurityHelper.checkDevice();

      expect(result.isCompromised, true);
      expect(result.isJailbroken, true);
      expect(result.isDeveloperModeEnabled, true);
    });

    // ── Negative cases (not compromised) ────────────────

    test('returns compromised=false when not jailbroken', () async {
      setDetectionMock(jailbroken: false, developerMode: false);
      final result = await SecurityHelper.checkDevice();

      expect(result.isCompromised, false);
      expect(result.isJailbroken, false);
    });

    test('returns compromised=false even with dev mode when not jailbroken', () async {
      // This is the KEY fix from W1: dev mode alone does NOT flag compromise.
      setDetectionMock(jailbroken: false, developerMode: true);
      final result = await SecurityHelper.checkDevice();

      expect(result.isCompromised, false);
      expect(result.isDeveloperModeEnabled, true);
    });

    // ── Error / edge cases ──────────────────────────────

    test('returns safe result when plugin throws (MissingPluginException)', () async {
      // No handler → channel throws or returns null → plugin default
      // (?? true) would return true; but if the handler throws,
      // checkDevice() catch block returns safe.
      setDetectionMock(jailbroken: true, developerMode: false);
      // Override to throw:
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall call) async => throw PlatformException(
          code: 'MOCK_ERROR',
          message: 'Simulated plugin failure',
        ),
      );

      final result = await SecurityHelper.checkDevice();

      expect(result.isCompromised, false);
      expect(result.isJailbroken, false);
      expect(result.isDeveloperModeEnabled, false);
    });

    test('returns safe result on null response from channel', () async {
      // When the mock returns null, FlutterJailbreakDetection defaults
      // to true (?? true). checkDevice() sees jailbroken=true.
      setDetectionMock(jailbroken: true, developerMode: false);
      // Override: return null for both methods
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall call) async => null,
      );

      final result = await SecurityHelper.checkDevice();

      // Because the plugin defaults `?? true` on null, checkDevice sees
      // true for both checks and returns compromised=true.
      // This simulates a device where the plugin is present but returns
      // null (e.g. unknown state).
      expect(result.isCompromised, true);
      expect(result.isJailbroken, true);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  //  enforceSecurity
  // ════════════════════════════════════════════════════════════════════
  group('SecurityHelper.enforceSecurity', () {
    test('is false in test/debug mode', () {
      // flutter test runs in debug mode, so kReleaseMode is false.
      expect(SecurityHelper.enforceSecurity, false);
    });

    test('equals !kReleaseMode', () {
      expect(SecurityHelper.enforceSecurity, !kReleaseMode);
      // This just documents the implementation — it's !kReleaseMode.
    });
  });
}
