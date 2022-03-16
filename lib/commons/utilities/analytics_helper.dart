import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static void logPageChange(String routeName) {
    FirebaseAnalytics.instance.logEvent(
      name: routeName,
    );
  }
}
