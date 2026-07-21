import 'dart:async';

import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:get_it/get_it.dart';

import 'app.dart';
import 'auth_token_store.dart';
import 'bootstrap/app_bootstrap.dart';
import 'core/analytics/firebase_service.dart';
import 'core/errors/forced_update_app.dart';
import 'core/feature_flags/feature_flag_service.dart';
import 'core/feature_flags/growthbook_service.dart';
import 'core/module_registry/module_registry.dart';
import 'core/security/security_helper.dart';
import 'core/shell/shell_version.dart';
import 'injection/app_injection.dart';
import 'security_blocked_app.dart';

import 'package:authentication_module/authentication_module.dart';
import 'package:resident_module/resident_module.dart';

// ══════════════════════════════════════════════════════════════════════
//  Entry Point
// ══════════════════════════════════════════════════════════════════════

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Security check must run before any token or module init.
  final securityResult = await SecurityHelper.checkDevice();
  final deviceBlocked =
      SecurityHelper.enforceSecurity && securityResult.isCompromised;

  // Firebase first so Crashlytics can capture bootstrap errors.
  await FirebaseService.initialize();

  if (deviceBlocked) {
    if (FirebaseService.isInitialized) {
      FirebaseService.crashlytics.log('Device jailbroken/rooted - access blocked');
      try {
        await FirebaseService.crashlytics.recordError(
          Exception('Jailbreak detected'),
          StackTrace.current,
          fatal: false,
        );
      } catch (_) {}
    }
    debugPrint('main: device security check FAILED — halting.');
    runApp(const SecurityBlockedApp());
    return;
  }

  runZonedGuarded(
    _bootstrap,
    (error, stack) {
      debugPrint('main: uncaught zoned error: $error');
      if (FirebaseService.isInitialized) {
        FirebaseService.crashlytics.recordError(error, stack, fatal: true);
      }
    },
  );
}

// ══════════════════════════════════════════════════════════════════════
//  Bootstrap
// ══════════════════════════════════════════════════════════════════════

Future<void> _bootstrap() async {
  final modules = <FeatureModule>[
    AuthenticationModule(),
    ResidentModule(),
  ];

  final result = await AppBootstrap.run(
    modules: modules,
    shellVersion: shellVersion,
    remoteFlagSource: null,
    skipCompatibilityCheck: true,
  );

  if (!result.success) {
    runApp(ForcedUpdateApp(message: result.error ?? 'Bootstrap failed'));
    return;
  }

  addPerformanceInterceptor();

  // Init token store and register in GetIt so interceptors and modules
  // can access it without prop-drilling.
  final tokenStore = AuthTokenStore();
  await tokenStore.init();
  GetIt.instance.registerSingleton<AuthTokenStore>(tokenStore);

  // GrowthBook runs in background — never blocks startup.
  final gbService = GrowthBookService();
  unawaited(_initGrowthBookAndRefresh(gbService, modules, result.registry));

  runApp(
    RtRwApp(
      registry: result.registry,
      gbService: gbService,
      tokenStore: tokenStore,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════
//  GrowthBook (background)
// ══════════════════════════════════════════════════════════════════════

Future<void> _initGrowthBookAndRefresh(
  GrowthBookService gbService,
  List<FeatureModule> modules,
  ModuleRegistry registry,
) async {
  await gbService.initialize(flagKeys: _collectFlagKeys(modules).toList());

  final remoteSource = gbService.createSource();
  if (remoteSource != null) {
    final ffService = FeatureFlagService(remoteSource: remoteSource);
    registry.setFeatureFlagService(ffService);
    await ffService.loadCached();
    await ffService.refreshRemote();
  }

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await registry.scheduleWarmup();
    registry.metrics.printReport();
  });
}

Set<String> _collectFlagKeys(List<FeatureModule> modules) {
  return {
    for (final module in modules) ...['${module.name}.enabled', '${module.name}.visible'],
  };
}
