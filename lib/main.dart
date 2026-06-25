import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:core_module/core_module.dart';
import 'package:resident_module/resident_module.dart';
import 'package:authentication_module/authentication_module.dart';
import 'package:authentication_module/presentation/bloc/auth_bloc.dart';
import 'package:authentication_module/presentation/bloc/auth_event.dart';
import 'package:authentication_module/presentation/bloc/auth_state.dart';
import 'package:authentication_module/presentation/pages/login_page.dart';
import 'package:authentication_module/presentation/pages/otp_verification_page.dart';

import 'auth_token_store.dart';
import 'bootstrap/app_bootstrap.dart';
import 'core/analytics/analytics.dart';
import 'core/analytics/firebase_service.dart';
import 'core/module_registry/module_registry.dart';
import 'core/feature_flags/feature_flag_service.dart';
import 'core/feature_flags/growthbook_service.dart';
import 'core/security/security_helper.dart';
import 'injection/app_injection.dart';
import 'security_blocked_app.dart';

/// Bridges [AuthBloc] stream to [ChangeNotifier] for GoRouter refresh.
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

final getIt = GetIt.instance;

// ══════════════════════════════════════════════════════════════════════
//  Shell Version
// ══════════════════════════════════════════════════════════════════════

/// Shell version — bump when breaking module contract changes occur.
const shellVersion = ModuleVersion(1, 0, 0);

// ══════════════════════════════════════════════════════════════════════
//  Entry Point
// ══════════════════════════════════════════════════════════════════════

Future<void> main() async {
  // ── Phase 0: Platform binding ───────────────────────
  WidgetsFlutterBinding.ensureInitialized();

  // ── Phase 0.1: Security check (BLOCKING) ────────────
  // Must run before any module or token initialisation so a compromised
  // device is rejected before it ever touches sensitive data.
  final securityResult = await SecurityHelper.checkDevice();
  final deviceBlocked =
      SecurityHelper.enforceSecurity && securityResult.isCompromised;

  // ── Phase 0.2: Firebase initialisation (BLOCKING) ───
  // Initialize before security block so we can log jailbreak events
  // Firebase must be ready before AppBootstrap so that:
  //   • Crashlytics catches any error thrown during bootstrap.
  //   • setupShellInjection() can resolve FirebaseService.isInitialized.
  await FirebaseService.initialize();

  // ── Phase 0.2.5: Log jailbreak detection if applicable ─
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

  // ── Phase 0.3: Error zone ────────────────────────────
  // Wrap the remaining startup in a guarded zone so that any async
  // error not caught by a framework hook is forwarded to Crashlytics.
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
//  Bootstrap (inside guarded zone)
// ══════════════════════════════════════════════════════════════════════

/// Runs the full module-registry bootstrap inside [runZonedGuarded].
///
/// Separated from [main] so the zone captures errors from every await
/// below, including [AppBootstrap.run], [AuthTokenStore.init], and the
/// background GrowthBook init.
Future<void> _bootstrap() async {
  // ── 1. Define Modules ───────────────────────────────
  final modules = <FeatureModule>[
    AuthenticationModule(),
    ResidentModule(),
    // Future: FinanceModule(), ComplaintModule(), MeetingModule(), SecurityModule()
  ];

  // ── 2. Bootstrap Shell (offline-first) ───────────────
  // GrowthBook init happens AFTER bootstrap — NEVER blocks startup.
  // setupShellInjection() is called inside AppBootstrap Phase 4,
  // registering Firebase services into GetIt before module DI runs.
  final result = await AppBootstrap.run(
    modules: modules,
    shellVersion: shellVersion,
    remoteFlagSource: null, // GrowthBook added post-bootstrap
    skipCompatibilityCheck: true,
  );

  if (!result.success) {
    runApp(ForcedUpdateApp(message: result.error ?? 'Bootstrap failed'));
    return;
  }

  // ── 2.5. Add Performance interceptor to Dio ──────
  addPerformanceInterceptor();

  // ── 3. Auth Token Store (shell-level) ───────────────
  final tokenStore = AuthTokenStore();
  await tokenStore.init();

  // ── 4. Init GrowthBook + Background Refresh ────────
  final gbService = GrowthBookService();
  // Non-blocking: GrowthBook init starts but never blocks UI.
  unawaited(_initGrowthBookAndRefresh(gbService, modules, result.registry));

  // ── 5. Run ──────────────────────────────────────────
  runApp(
    RtRwApp(
      registry: result.registry,
      gbService: gbService,
      tokenStore: tokenStore,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════
//  Helpers
// ══════════════════════════════════════════════════════════════════════

/// Collect all known feature flag keys from module manifests.
///
/// Generates standard flag keys: `<module>.enabled`, `<module>.visible`.
Set<String> _collectFlagKeys(List<FeatureModule> modules) {
  return {
    for (final module in modules)
      ...[
        '${module.name}.enabled',
        '${module.name}.visible',
      ],
  };
}

// ══════════════════════════════════════════════════════════════════════
//  Root App
// ══════════════════════════════════════════════════════════════════════

/// Root application widget with module-registry-driven routing.
class RtRwApp extends StatefulWidget {
  final ModuleRegistry registry;
  final GrowthBookService? gbService;
  final AuthTokenStore? tokenStore;

  const RtRwApp({
    super.key,
    required this.registry,
    this.gbService,
    this.tokenStore,
  });

  @override
  State<RtRwApp> createState() => _RtRwAppState();
}

/// Initialize GrowthBook SDK and refresh flags in background.
///
/// This runs after the app is already visible to the user.
/// GrowthBook unavailability NEVER blocks startup.
Future<void> _initGrowthBookAndRefresh(
  GrowthBookService gbService,
  List<FeatureModule> modules,
  ModuleRegistry registry,
) async {
  // 1. Init GrowthBook SDK (may fail — non-fatal)
  await gbService.initialize(
    flagKeys: _collectFlagKeys(modules).toList(),
  );

  // 2. Set remote source on existing flag service
  final remoteSource = gbService.createSource();
  if (remoteSource != null) {
    // Create a new FeatureFlagService with remote source
    final ffService = FeatureFlagService(
      remoteSource: remoteSource,
      // Reuse existing local cache if any — not strictly needed for now
    );
    registry.setFeatureFlagService(ffService);
    await ffService.loadCached();
    await ffService.refreshRemote();
  }

  // 3. Schedule warmup + background work after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await registry.scheduleWarmup();
    registry.metrics.printReport();
  });
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
    _authBloc = getIt<AuthBloc>();
    _analytics = getIt<AnalyticsService>();
    _crashlytics = getIt<CrashlyticsService>();

    // Listen to auth state changes for analytics + crashlytics
    _authSubscription = _authBloc.stream.listen(_onAuthStateChanged);

    // Log initial screen
    _analytics.logScreenView(screenName: 'App');

    _redirectNotifier = AuthRedirectNotifier(_authBloc);
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: _redirectNotifier,
      redirect: _authRedirect,
      routes: [
        // Auth routes (outside shell — no nav drawer)
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => _withScreenView(
            'Login',
            BlocProvider.value(value: _authBloc, child: const LoginPage()),
          ),
        ),
        GoRoute(
          path: '/register-verify',
          name: 'register.verify',
          builder: (context, state) => _withScreenView(
            'OtpVerification',
            BlocProvider.value(
              value: _authBloc,
              child: OtpVerificationPage(
                phone: state.uri.queryParameters['phone'] ?? '',
              ),
            ),
          ),
        ),
        // Shell + module routes
        ShellRoute(
          builder: (context, state, child) => AppShell(
            registry: widget.registry,
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => _withScreenView(
                'Dashboard',
                DashboardPage(
                  registry: widget.registry,
                  tokenStore: widget.tokenStore,
                  onLogout: () => _authBloc.add(const LogoutRequested()),
                ),
              ),
            ),
            // Module-owned routes (auto-registered)
            ...widget.registry.allRoutes,
          ],
        ),
      ],
    );

    // Check auth status on init
    _authBloc.add(const CheckAuthStatus());
  }

  /// Redirect to /login if not authenticated.
  String? _authRedirect(BuildContext context, GoRouterState state) {
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register-verify';
    final isAuthenticated = _authBloc.state is AuthAuthenticated;

    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }
    if (isAuthenticated && isAuthRoute) {
      return '/';
    }
    return null;
  }

  void _onAuthStateChanged(AuthState state) {
    if (state is AuthAuthenticated) {
      _analytics.logEvent('login_success');
      _analytics.setUserId(state.user.id.toString());
      _analytics.setUserProperty(name: 'role', value: 'resident');
      _crashlytics.setUserId(state.user.id.toString());
      _crashlytics.log('User authenticated: ${state.user.id}');
    } else if (state is AuthUnauthenticated) {
      _analytics.logEvent('logout');
      _analytics.setUserId(null);
    } else if (state is AuthError) {
      _analytics.logEvent('login_failed', parameters: {
        'reason': state.message,
      });
    }
  }

  /// Wrap [child] with a widget that logs a screen view on first build.
  Widget _withScreenView(String name, Widget child) {
    if (name != _lastScreenView) {
      _lastScreenView = name;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _analytics.logScreenView(screenName: name);
      });
    }
    return child;
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

// ══════════════════════════════════════════════════════════════════════
//  App Shell / Navigation
// ══════════════════════════════════════════════════════════════════════

/// Shell scaffold with navigation drawer driven by module registry.
class AppShell extends StatelessWidget {
  final ModuleRegistry registry;
  final Widget child;

  const AppShell({
    super.key,
    required this.registry,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final modules = registry.enabledModules
        .where((m) => registry.isVisible(m.name))
        .toList();

    return Scaffold(
      body: child,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'RT-RW Digital',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v${shellVersion.asString}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/');
              },
            ),
            const Divider(),
            ...modules.map((module) => ListTile(
                  leading: const Icon(Icons.widgets_outlined),
                  title: Text(module.displayName),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/${module.name}');
                  },
                )),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  Dashboard
// ══════════════════════════════════════════════════════════════════════

/// Dashboard showing enabled modules as tappable cards.
class DashboardPage extends StatelessWidget {
  final ModuleRegistry registry;
  final AuthTokenStore? tokenStore;
  final VoidCallback? onLogout;

  const DashboardPage({
    super.key,
    required this.registry,
    this.tokenStore,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final modules = registry.enabledModules
        .where((m) => registry.isVisible(m.name))
        .toList();
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RT-RW Digital'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (authState is AuthAuthenticated)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  authState.user.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: onLogout,
          ),
        ],
      ),
      body: modules.isEmpty
          ? const Center(child: Text('No modules enabled'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return Card(
                  child: InkWell(
                    onTap: () => context.go('/${module.name}'),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.widgets, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            module.displayName,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'v${module.version.asString}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  Fallback
// ══════════════════════════════════════════════════════════════════════

/// Forced update / error screen shown when bootstrap fails.
class ForcedUpdateApp extends StatelessWidget {
  final String? message;

  const ForcedUpdateApp({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Application Update Required',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(message ?? 'A compatibility issue was detected.'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Update Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
