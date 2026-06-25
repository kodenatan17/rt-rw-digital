import 'package:core_module/core_module.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

// ══════════════════════════════════════════════════════════════════════
//  PerformanceTrace wrapper
// ══════════════════════════════════════════════════════════════════════

/// Opaque handle for an in-flight performance trace.
///
/// Start via [PerformanceService.startTrace]; finalise via [stop].
class FirebasePerformanceTrace implements PerformanceTrace {
  final Trace _trace;

  FirebasePerformanceTrace(this._trace);

  /// Finish the trace and send timing data to Firebase.
  @override
  Future<void> stop() => _trace.stop();

  /// Increment a named metric by [value].
  @override
  void incrementMetric(String name, int value) =>
      _trace.incrementMetric(name, value);

  /// Set (or overwrite) a named metric to [value].
  @override
  void setMetric(String name, int value) => _trace.setMetric(name, value);

  /// Attach a string attribute for filtering/grouping in the console.
  @override
  void putAttribute(String name, String value) =>
      _trace.putAttribute(name, value);
}

// ══════════════════════════════════════════════════════════════════════
//  Firebase implementation
// ══════════════════════════════════════════════════════════════════════

/// [PerformanceService] backed by [FirebasePerformance].
class FirebasePerformanceService implements PerformanceService {
  final FirebasePerformance _performance;

  FirebasePerformanceService(this._performance);

  @override
  Future<PerformanceTrace?> startTrace(String name) async {
    try {
      final trace = _performance.newTrace(name);
      await trace.start();
      debugPrint('Performance: trace "$name" started.');
      return FirebasePerformanceTrace(trace);
    } catch (e) {
      debugPrint('Performance: failed to start trace "$name": $e');
      return null;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
//  No-op implementation
// ══════════════════════════════════════════════════════════════════════

/// Silent [PerformanceService] for tests / when Firebase failed to init.
class NoOpPerformanceService implements PerformanceService {
  const NoOpPerformanceService();

  @override
  Future<PerformanceTrace?> startTrace(String name) async => null;
}