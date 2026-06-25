import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:resident_module/injection/resident_injection.dart';
import 'package:authentication_module/injection/authentication_injection.dart';

import '../core/analytics/performance_dio_interceptor.dart';
import 'shell_injection.dart';

void setupInjection() {
  setupShellInjection();
  setupCoreInjection();
  addPerformanceInterceptor();
  setupAuthenticationInjection();
  setupResidentInjection();
}

/// Add [PerformanceDioInterceptor] to the registered [Dio] instance.
///
/// Safe to call multiple times — checks for duplicate.
/// Must be called after [setupCoreInjection] so Dio and PerformanceService
/// are already registered in [GetIt].
void addPerformanceInterceptor() {
  final dio = GetIt.instance<Dio>();
  final hasPerfInterceptor =
      dio.interceptors.any((i) => i is PerformanceDioInterceptor);
  if (hasPerfInterceptor) return;
  dio.interceptors.add(
    PerformanceDioInterceptor(GetIt.instance<PerformanceService>()),
  );
}
