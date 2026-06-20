import 'package:core_module/injection/core_injection.dart';
import 'package:resident_module/injection/resident_injection.dart';
import 'package:authentication_module/injection/authentication_injection.dart';

/// Order matters: core → auth → features
void setupInjection() {
  setupCoreInjection();
  setupAuthenticationInjection();
  setupResidentInjection();
}
