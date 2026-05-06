import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

@injectable
class FirebaseAnalyticsHelper {
  FirebaseAnalytics? _analytics;

  FirebaseAnalytics get instance {
    return _analytics ??= FirebaseAnalytics.instance;
  }

  void logEvent(String name, {Map<String, dynamic>? params}) {
    if (params == null) {
      instance.logEvent(name: name);
      return;
    }

    instance.logEvent(  
      name: name,
      parameters: Map<String, Object>.from(params),
    );
  }

  Future<void> screenView({
    required String screenName,
    String? tab,
    required String eventCategory,
  }) async {
    return instance.logScreenView(
      screenName: screenName,
      parameters: {
        if (tab != null) ...{'tab': tab},
        'event_category': eventCategory,
      },
    );
  }

  Future<void> menuClick({
    required String screenName,
    required String eventCategory,
    String? tab,
    String? event,
  }) async {
    return instance.logEvent(
      name: 'menu_click',
      parameters: {
        'screen_name': screenName,
        'event_category': eventCategory,
        if (tab != null) ...{'tab': tab},
        if (event != null) ...{'event': event},
      },
    );
  }
}
