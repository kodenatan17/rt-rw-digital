import 'dart:async';

import 'package:authentication_module/presentation/bloc/auth_bloc.dart';
import 'package:authentication_module/presentation/bloc/auth_event.dart';
import 'package:authentication_module/presentation/bloc/auth_state.dart';
import 'package:authentication_module/presentation/bloc/login/auth_login_bloc.dart';
import 'package:authentication_module/presentation/bloc/otp/auth_otp_bloc.dart';
import 'package:authentication_module/presentation/pages/login_page.dart';
import 'package:authentication_module/presentation/pages/otp_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../auth_token_store.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../module_registry/module_registry.dart';
import '../shell/app_shell.dart';

/// Bridges [AuthBloc] stream to [ChangeNotifier] so GoRouter re-evaluates
/// the redirect guard on every auth state change.
class AuthRedirectNotifier extends ChangeNotifier {
  StreamSubscription<AuthState>? _subscription;

  AuthRedirectNotifier(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Builds and owns the app's [GoRouter].
///
/// Encapsulates route definitions and the auth redirect guard so [RtRwApp]
/// stays focused on state management and lifecycle.
class AppRouter {
  final ModuleRegistry registry;
  final AuthBloc authBloc;
  final AuthTokenStore? tokenStore;
  final void Function(String screenName)? onScreenView;

  AppRouter({
    required this.registry,
    required this.authBloc,
    this.tokenStore,
    this.onScreenView,
  });

  GoRouter build(AuthRedirectNotifier redirectNotifier) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: redirectNotifier,
      redirect: _guard,
      routes: [
        // ── Auth routes (no shell / nav drawer) ──────────
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            onScreenView?.call('Login');
            return BlocProvider(
              create: (_) => GetIt.instance<AuthLoginBloc>(),
              child: const LoginPage(),
            );
          },
        ),
        GoRoute(
          path: '/register-verify',
          name: 'register.verify',
          builder: (context, state) {
            onScreenView?.call('OtpVerification');
            return BlocProvider(
              create: (_) => GetIt.instance<AuthOtpBloc>(),
              child: OtpVerificationPage(
                phone: state.uri.queryParameters['phone'] ?? '',
              ),
            );
          },
        ),
        // ── Authenticated shell ───────────────────────────
        ShellRoute(
          builder: (context, state, child) => AppShell(
            registry: registry,
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) {
                onScreenView?.call('Dashboard');
                return DashboardPage(
                  registry: registry,
                  tokenStore: tokenStore,
                  onLogout: () => authBloc.add(const LogoutRequested()),
                );
              },
            ),
            // Module-owned routes registered by each FeatureModule
            ...registry.allRoutes,
          ],
        ),
      ],
    );
  }

  String? _guard(BuildContext context, GoRouterState state) {
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register-verify';
    final isAuthenticated = authBloc.state is AuthAuthenticated;

    if (!isAuthenticated && !isAuthRoute) return '/login';
    if (isAuthenticated && isAuthRoute) return '/';
    return null;
  }
}
