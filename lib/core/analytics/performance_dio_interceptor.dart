import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';

class PerformanceDioInterceptor extends Interceptor {
  final PerformanceService _performance;

  PerformanceDioInterceptor(this._performance);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final path = options.path;
      if (path.startsWith('/')) {
        final traceName = 'http_${options.method}_$path';
        // Fire-and-forget: trace starts async, handler.next immediately
        _performance.startTrace(traceName).then((trace) {
          if (trace != null) {
            options.extra['perf_trace'] = trace;
            options.extra['perf_start'] =
                DateTime.now().millisecondsSinceEpoch;
          }
        });
      }
    } catch (_) {
      // Swallow — interceptor must never crash.
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final trace =
          response.requestOptions.extra['perf_trace'] as PerformanceTrace?;
      if (trace != null) {
        final start =
            response.requestOptions.extra['perf_start'] as int? ?? 0;
        final duration = DateTime.now().millisecondsSinceEpoch - start;

        trace.setMetric('duration_ms', duration);
        trace.setMetric('status_code', response.statusCode ?? 0);
        trace.putAttribute('success', 'true');
        trace.stop();
      }
    } catch (_) {
      // Swallow.
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      final trace =
          err.requestOptions.extra['perf_trace'] as PerformanceTrace?;
      if (trace != null) {
        final start = err.requestOptions.extra['perf_start'] as int? ?? 0;
        final duration = DateTime.now().millisecondsSinceEpoch - start;

        trace.setMetric('duration_ms', duration);
        trace.setMetric('status_code', err.response?.statusCode ?? 0);
        trace.putAttribute('success', 'false');
        trace.stop();
      }
    } catch (_) {
      // Swallow.
    }
    handler.next(err);
  }
}
