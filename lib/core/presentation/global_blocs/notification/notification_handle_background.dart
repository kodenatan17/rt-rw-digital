import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:pasconnect/features/call/data/services/call_deny_registry.dart';
import 'package:pasconnect/features/call/data/services/call_notification_channels.dart';
import 'package:pasconnect/features/notification/domain/data/notification_content_data.dart';
import 'package:pasconnect/firebase_options.dart';

/// Background FCM Notification Handler
///
/// Handles FCM messages when app is in background or terminated.
/// This runs in a separate isolate with limited platform access.
class NotificationHandleBackground {
  /// Main entry point for background FCM messages
  static Future<void> handleNotif(RemoteMessage message) async {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('[FCM Background] Message ID: ${message.messageId}');
    debugPrint('[FCM Background] Data: ${message.data}');
    debugPrint('═══════════════════════════════════════════════════════════');

    await _initializeFirebase();

    final content = NotificationContentData.fromRemote(message);
    debugPrint(
      '[FCM Background] Action: ${content.call}, Type: ${content.callType}',
    );

    if (content.isCallEndNotification) {
      await _handleCallEnd();
    } else if (_isValidIncomingCall(content)) {
      await _showIncomingCall(content);
    } else {
      debugPrint('[FCM Background] Not a call notification, ignoring');
    }
  }

  /// Check if this is a valid incoming call notification
  static bool _isValidIncomingCall(NotificationContentData content) {
    final isValid = content.callType != null &&
        content.agoraToken != null &&
        !content.isCallEnd;
    
    if (!isValid) {
      debugPrint(
        '[FCM Background] ❌ Invalid call - callType: ${content.callType}, '
        'agoraToken: ${content.agoraToken != null ? "present" : "null"}, '
        'isCallEnd: ${content.isCallEnd}',
      );
    } else {
      debugPrint('[FCM Background] ✅ Valid incoming call detected');
    }
    
    return isValid;
  }

  /// Initialize Firebase for background isolate
  static Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.backgroundPlatform,
      );
      debugPrint('[FCM Background] Firebase initialized');
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
      debugPrint('[FCM Background] Firebase already initialized');
    }
  }

  /// Handle call END notification
  static Future<void> _handleCallEnd() async {
    debugPrint('[FCM Background] END notification - ending all calls');
    try {
      await FlutterCallkitIncoming.endAllCalls();
    } catch (e) {
      debugPrint('[FCM Background] Error ending calls: $e');
    }
  }

  /// Show incoming call notification
  static Future<void> _showIncomingCall(NotificationContentData content) async {
    try {
      final callId =
          content.callId ?? 'call_${DateTime.now().millisecondsSinceEpoch}';

      // Guard 1: check if this callId was already denied / ended by the user.
      // This handles the FCM-retry scenario where notification 1 was rejected
      // and notification 2 (same callId, higher TTL) arrives afterwards.
      if (await CallDenyRegistry.isDenied(callId)) {
        debugPrint(
          '[FCM Background] callId $callId already denied — ignoring duplicate notification',
        );
        return;
      }

      // Guard 2: reject concurrent duplicate — if ANY call is already ringing,
      // enforce single-call behaviour regardless of callId.
      final activeCalls = await FlutterCallkitIncoming.activeCalls();
      if ((activeCalls as List<dynamic>).isNotEmpty) {
        debugPrint(
          '[FCM Background] Already ringing (${activeCalls.length} active call(s)) – ignoring incoming notification for $callId',
        );
        return;
      }

      // CRITICAL FIX: Mark callId as active IMMEDIATELY to prevent race conditions.
      // When duplicate notifications arrive simultaneously (backend sends 2 FCM messages),
      // both check the registry at the same time (both see it empty), then both show.
      // By adding to registry NOW, notification 2 will be blocked at Guard 1.
      await CallDenyRegistry.deny(callId);
      debugPrint('[FCM Background] ✅ Marked callId as active/shown in registry');

      final isVideo = content.isVideoCall;

      debugPrint('[FCM Background] Showing incoming call - isVideo: $isVideo');

      final params = CallKitParams(
        id: callId,
        nameCaller: 'Pas Connect',
        appName: 'Pas Connect',
        avatar: CallNotificationChannels.defaultAvatarAsset,
        handle: CallNotificationChannels.incomingHandleText,
        type: isVideo ? 1 : 0,
        textAccept: isVideo
            ? CallNotificationChannels.acceptVideoText
            : CallNotificationChannels.acceptVoiceText,
        textDecline: CallNotificationChannels.declineText,
        duration: 30000,
        extra: _buildExtraData(content, callId),
        headers: {},
        android: _buildAndroidParams(isVideo),
        ios: _buildIOSParams(isVideo),
      );

      await FlutterCallkitIncoming.showCallkitIncoming(params);
      debugPrint('[FCM Background] Incoming call displayed successfully');
    } catch (e) {
      debugPrint('[FCM Background] Error showing incoming call: $e');
    }
  }

  /// Build extra data for call
  static Map<String, dynamic> _buildExtraData(
    NotificationContentData content,
    String callId,
  ) {
    return {
      'agoraToken': content.agoraToken ?? '',
      'call': content.call ?? '',
      'callId': callId,
      'callType': content.normalizedCallType,
      'agoraId': content.agoraId!,
      'requiresUnlock': content.isVideoCall,
    };
  }

  /// Build Android-specific parameters
  static AndroidParams _buildAndroidParams(bool isVideo) {
    return const AndroidParams(
      // Use system call style for better spacing/padding consistency and
      // lock-screen rendering on Android 13/14+ across OEM skins.
      isCustomNotification: false,
      isShowLogo: false,
      isShowFullLockedScreen: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0A1929',
      backgroundUrl: '',
      actionColor: '#5FD4A3',
      textColor: '#FFFFFF',
      incomingCallNotificationChannelName:
          CallNotificationChannels.voipIncomingName,
      missedCallNotificationChannelName:
          CallNotificationChannels.voipMissedName,
      isShowCallID: true,
      // Keep standard small heads-up layout to avoid icon-only compact UI
      // on certain OEM Android skins.
      isCustomSmallExNotification: false,
      isImportant: true,
    );
  }

  /// Build iOS-specific parameters (WhatsApp-like native CallKit)
  static IOSParams _buildIOSParams(bool isVideo) {
    return IOSParams(
      iconName: 'CallKitLogo',
      handleType: 'generic',
      supportsVideo: isVideo,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: isVideo ? 'videoChat' : 'voiceChat',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    );
  }
}
