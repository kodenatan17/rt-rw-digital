import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';

class FirebasePerformanceHelper extends InterceptorsWrapper {
  final String domainPath;

  FirebasePerformanceHelper({
    required this.domainPath,
  });

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path.contains(domainPath)) {
      final trace = FirebasePerformance.instance.newTrace(options.path);
      await trace.start();
      options.extra['firebaseTrace'] = trace;
      options.extra['requestStartTime'] = DateTime.now().millisecondsSinceEpoch;
      trace.putAttribute('method', options.method);
      trace.putAttribute('url', options.uri.toString());
    }
    handler.next(options); // continue to the next interceptor
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final trace = response.requestOptions.extra['firebaseTrace'] as Trace?;
    if (trace != null) {
      final requestStartTime =
          response.requestOptions.extra['requestStartTime'] as int?;
      if (requestStartTime != null) {
        final requestDuration =
            DateTime.now().millisecondsSinceEpoch - requestStartTime;
        trace.setMetric('request_duration_ms', requestDuration);
      }
      trace.setMetric('response_size_bytes', response.data.toString().length);
      trace.putAttribute('status_code', response.statusCode.toString());
      trace.putAttribute('success', 'true');
      await trace.stop();
    }
    handler.next(response); // continue to the next interceptor
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final trace = err.requestOptions.extra['firebaseTrace'] as Trace?;
    if (trace != null) {
      final requestStartTime =
          err.requestOptions.extra['requestStartTime'] as int?;
      if (requestStartTime != null) {
        final requestDuration =
            DateTime.now().millisecondsSinceEpoch - requestStartTime;
        trace.setMetric('request_duration_ms', requestDuration);
      }
      trace.setMetric('response_size_bytes', 0);
      trace.putAttribute('status_code', err.response?.statusCode?.toString() ?? 'unknown');
      trace.putAttribute('success', 'false');
      await trace.stop();
    }
    handler.next(err);
  }
}
