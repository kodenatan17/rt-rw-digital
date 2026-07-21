import 'dart:async';

import 'package:authentication_module/presentation/bloc/auth_bloc.dart';
import 'package:authentication_module/presentation/bloc/auth_event.dart';
import 'package:authentication_module/presentation/bloc/auth_state.dart';
import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'auth_token_store.dart';
import 'core/feature_flags/growthbook_service.dart';
import 'core/module_registry/module_registry.dart';
import 'core/routing/app_router.dart';

class RtRwApp extends StatefulWidget {
  final ModuleRegistry registry;
  final GrowthBookService? gbService;
  final AuthTokenStore tokenStore;

  const RtRwApp({
    super.key,
    required this.registry,
    required this.tokenStore,
    this.gbService,
  });

  @override
  State<RtRwApp> createState() => _RtRwAppState();
}

class _RtRwAppState extends State<RtRwApp> {
  late final GoRouter _router;
  late final AuthBloc _authBloc;
  late final AuthRedirectNotifier _redirectNotifier;
  late final AnalyticsService _analytics;
  late final CrashlyticsService _crashlytics;
  StreamSubscription<AuthState>? _authSubscription;
  String? _lastScreenView;

  @override
  void initState() {
    super.initState();
    _authBloc = GetIt.instance<AuthBloc>();
    _analytics = GetIt.instance<AnalyticsService>();
    _crashlytics = GetIt.instance<CrashlyticsService>();

    _authSubscription = _authBloc.stream.listen(_onAuthStateChanged);

    _analytics.logScreenView(screenName: 'App');

    _redirectNotifier = AuthRedirectNotifier(_authBloc);
    _router = AppRouter(
      registry: widget.registry,
      authBloc: _authBloc,
      tokenStore: widget.tokenStore,
      onScreenView: _logScreenView,
    ).build(_redirectNotifier);

    _authBloc.add(const CheckAuthStatus());
  }

  // ── Auth state handler ────────────────────────────────

  void _onAuthStateChanged(AuthState state) {
    if (state is AuthAuthenticated) {
      // Sync shell token store so UI listeners see the current tokens.
      widget.tokenStore.saveTokens(
        accessToken: state.token,
        refreshToken: state.refreshToken,
      );
      _analytics.logEvent('login_success');
      _analytics.setUserId(state.user.id.toString());
      _analytics.setUserProperty(name: 'role', value: 'resident');
      _crashlytics.setUserId(state.user.id.toString());
      _crashlytics.log('User authenticated: ${state.user.id}');
    } else if (state is AuthUnauthenticated) {
      // Clear shell store on logout / session expiry.
      widget.tokenStore.clear();
      _analytics.logEvent('logout');
      _analytics.setUserId(null);
    }
  }

  // ── Screen view logging ───────────────────────────────

  void _logScreenView(String name) {
    if (name != _lastScreenView) {
      _lastScreenView = name;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _analytics.logScreenView(screenName: name);
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _router.dispose();
    _redirectNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'RT-RW Digital',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
