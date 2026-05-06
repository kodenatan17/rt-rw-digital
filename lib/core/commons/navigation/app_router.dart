import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:go_router/go_router.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:pasconnect/core/commons/navigation/app_routes.dart';
import 'package:pasconnect/features/auth/presentation/page/complete_screen.dart';
import 'package:pasconnect/features/auth/presentation/page/login_screen.dart';
import 'package:pasconnect/features/auth/presentation/page/splash_screen.dart';
import 'package:pasconnect/features/auth/presentation/page/verification_screen.dart';
import 'package:pasconnect/features/call/presentation/page/call_screen.dart';
import 'package:pasconnect/features/user/presentation/home/bloc/home_cubit.dart';
import 'package:pasconnect/features/user/presentation/home/page/home_screen.dart';

// Global navigator key for navigation from outside widget tree
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Check if there's an active/pending incoming call from CallKit
/// Returns call data if found, null otherwise
Future<Map<String, String>?> _checkPendingCall() async {
  try {
    final activeCalls = await FlutterCallkitIncoming.activeCalls();
    if (activeCalls.isNotEmpty) {
      for (final rawCall in activeCalls) {
        if (rawCall is! Map) continue;

        final call = rawCall as Map<dynamic, dynamic>;
        final extra = call['extra'] as Map<dynamic, dynamic>?;
        final isAccepted = call['isAccepted'] == true;

        final callId =
            extra?['callId']?.toString() ?? call['id']?.toString() ?? '';
        final agoraToken = extra?['agoraToken']?.toString() ?? '';
        final typeCall = extra?['callType']?.toString() ?? 'VOICE';
        final rawCallAction = extra?['call']?.toString().toUpperCase() ?? '';

        // Defensive filter to avoid ghost call redirect from stale native entries.
        // We only redirect when payload still has minimum call context.
        if (callId.isEmpty || agoraToken.isEmpty) {
          continue;
        }

        // END entries are stale for routing purposes.
        if (rawCallAction == 'END') {
          continue;
        }

        // `callAction=START` in CallScreen means "already accepted from CallKit".
        // FCM payload `call=START` only means incoming call notification, not acceptance.
        // So we derive acceptance from native `isAccepted` flag instead.
        final callAction = isAccepted ? 'START' : '';

        return {
          'callId': callId,
          'agoraToken': agoraToken,
          'agoraId':
              extra?['agoraId']?.toString() ??
              call['nameCaller']?.toString() ??
              '',
          'typeCall': typeCall,
          'callAction': callAction,
        };
      }
    }
  } catch (e) {
    debugPrint('[Router] Error checking pending calls: $e');
  }
  return null;
}

/// App router with call-aware navigation
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  observers: [ChuckerFlutter.navigatorObserver],

  // Redirect to call screen if there's a pending call
  redirect: (context, state) async {
    // Skip redirect if already on call screen
    if (state.matchedLocation == '/call') return null;

    // Check for pending calls
    final pendingCall = await _checkPendingCall();
    if (pendingCall != null) {
      debugPrint('[Router] Pending call detected, redirecting to call screen');
      final uri = Uri(path: '/call', queryParameters: pendingCall);
      return uri.toString();
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/splash',
      name: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      name: AppRoutes.verifyOtp,
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        final phoneNumber = state.uri.queryParameters['phoneNumber'] ?? '';
        return VerificationScreen(token: token, phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: '/complete-profile',
      name: AppRoutes.completeProfile,
      builder: (context, state) => const CompleteScreen(),
    ),
    GoRoute(
      path: '/home',
      name: AppRoutes.home,
      builder: (context, state) => BlocProvider(
        create: (context) => HomeCubit(),
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/call',
      name: AppRoutes.call,
      builder: (context, state) {
        final callId = state.uri.queryParameters['callId'];
        final uid = state.uri.queryParameters['agoraId'];
        final agoraToken = state.uri.queryParameters['agoraToken'];
        final typeCall = state.uri.queryParameters['typeCall'];
        final callAction = state.uri.queryParameters['callAction'];
        return CallScreen(
          callId: callId,
          agoraToken: agoraToken,
          uid: uid,
          typeCall: typeCall,
          callAction: callAction,
        );
      },
    ),
  ],
);
