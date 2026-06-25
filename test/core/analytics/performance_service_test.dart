import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rt_rw_digital/core/analytics/performance_service.dart';

// ══════════════════════════════════════════════════════════════════════
//  Mockito mocks
// ══════════════════════════════════════════════════════════════════════

class MockFirebasePerformance extends Mock implements FirebasePerformance {}

class MockTrace extends Mock implements Trace {}

// ══════════════════════════════════════════════════════════════════════
//  PerformanceTrace wrapper tests
// ══════════════════════════════════════════════════════════════════════

void main() {
  group('PerformanceTrace', () {
    late MockTrace mockTrace;
    late PerformanceTrace trace;

    setUp(() {
      mockTrace = MockTrace();
      trace = PerformanceTrace(mockTrace);
    });

    test('stop delegates to underlying Trace.stop', () async {
      await trace.stop();
      verify(mockTrace.stop()).called(1);
    });

    test('incrementMetric delegates to underlying Trace', () {
      trace.incrementMetric('hits', 1);
      verify(mockTrace.incrementMetric('hits', 1)).called(1);
    });

    test('setMetric delegates to underlying Trace', () {
      trace.setMetric('item_count', 42);
      verify(mockTrace.setMetric('item_count', 42)).called(1);
    });

    test('putAttribute delegates to underlying Trace', () {
      trace.putAttribute('source', 'test_screen');
      verify(mockTrace.putAttribute('source', 'test_screen')).called(1);
    });

    test('multiple operations on same trace', () async {
      trace.setMetric('items', 10);
      trace.incrementMetric('retries', 1);
      await trace.stop();

      verify(mockTrace.setMetric('items', 10)).called(1);
      verify(mockTrace.incrementMetric('retries', 1)).called(1);
      verify(mockTrace.stop()).called(1);
    });
  });

  // ── FirebasePerformanceService tests ──────────────────────────────
  group('FirebasePerformanceService', () {
    late MockFirebasePerformance mockPerformance;
    late FirebasePerformanceService service;

    setUp(() {
      mockPerformance = MockFirebasePerformance();
      service = FirebasePerformanceService(mockPerformance);
    });

    test('startTrace returns PerformanceTrace on success', () async {
      when(mockPerformance.newTrace('test_trace')).thenReturn(MockTrace());
      final result = await service.startTrace('test_trace');

      expect(result, isNotNull);
      expect(result, isA<PerformanceTrace>());
      verify(mockPerformance.newTrace('test_trace')).called(1);
    });

    test('startTrace starts the underlying trace', () async {
      final mockTrace = MockTrace();
      when(mockPerformance.newTrace('timed_op')).thenReturn(mockTrace);

      await service.startTrace('timed_op');

      verify(mockTrace.start()).called(1);
    });

    test('startTrace returns null when FirebasePerformance throws', () async {
      when(mockPerformance.newTrace(any))
          .thenThrow(Exception('Plugin not available'));
      final result = await service.startTrace('test');

      expect(result, isNull);
    });

    test('startTrace returns null when newTrace fails', () async {
      when(mockPerformance.newTrace(any)).thenThrow(Exception('Init error'));
      final result = await service.startTrace('fail_trace');

      expect(result, isNull);
    });
  });

  // ── NoOpPerformanceService tests ──────────────────────────────────
  group('NoOpPerformanceService', () {
    late NoOpPerformanceService noop;

    setUp(() {
      noop = const NoOpPerformanceService();
    });

    test('startTrace returns null', () async {
      final result = await noop.startTrace('any');
      expect(result, isNull);
    });

    test('multiple startTrace calls all return null', () async {
      final r1 = await noop.startTrace('a');
      final r2 = await noop.startTrace('b');
      expect(r1, isNull);
      expect(r2, isNull);
    });

    test('const constructor returns canonical instance', () {
      expect(
        const NoOpPerformanceService(),
        same(const NoOpPerformanceService()),
      );
    });
  });
}
