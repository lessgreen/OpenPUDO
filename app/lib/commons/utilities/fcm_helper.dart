import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/app.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/trace_reflection.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/commons/utilities/print_helper.dart';
import 'package:qui_green/models/base_response.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

Future<void> initFirebaseMessaging() async {
  //Firebase stuff
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails? launchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (launchDetails != null) {
    safePrint(launchDetails.notificationResponse?.payload ?? "");
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  /// Create an Android Notification Channel.
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> firebaseMessagingHandler(Function contextGetter, RemoteMessage? message) async {
  if (message != null) {
    if (message.data.containsKey("notificationType")) {
      if (message.data["notificationType"] == "package") {
        if (message.data.containsKey("packageId")) {
          handlePackageRouting(contextGetter(), message.data['notificationId'], int.parse(message.data["packageId"]));
        }
      } else if (message.data["notifitcationType"] == "favourite") {
        if (message.data.containsKey("userId")) {
          handleUserRouting(contextGetter(), message.data['notificationId'], int.parse(message.data["userId"]));
        }
      }
    }
  }
}

Future<void> firebaseMessagingOpenedAppHandler(Function contextGetter, RemoteMessage? message) async {
  if (message != null) {
    ///Refresh home
    CurrentUser currentUser = Provider.of<CurrentUser>(contextGetter(), listen: false);
    String pageName = TraceReflection.stackFrame(2)?.first ?? 'general';
    if (currentUser.user != null) {
      if (pageName == "HomeControllerState") {
        currentUser.triggerReload();
      }
    }
    currentUser.unreadNotifications++;

    /// Show material banner
    ScaffoldMessenger.of(contextGetter()).showMaterialBanner(MaterialBanner(
      backgroundColor: const Color.fromRGBO(254, 227, 183, 1),
      content: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(contextGetter()).clearMaterialBanners();
            if (message.data.containsKey("notificationType")) {
              if (message.data["notificationType"] == "package") {
                if (message.data.containsKey("packageId")) {
                  handlePackageRouting(contextGetter(), message.data['notificationId'], int.parse(message.data["packageId"]));
                }
              } else if (message.data["notifitcationType"] == "favourite") {
                if (message.data.containsKey("userId")) {
                  handleUserRouting(contextGetter(), message.data['notificationId'], int.parse(message.data["userId"]));
                }
              }
            }
          },
          child: Text(message.notification?.body ?? "")),
      actions: const [SizedBox()],
      onVisible: () {
        Future.delayed(const Duration(seconds: 6), () {
          ScaffoldMessenger.of(contextGetter()).clearMaterialBanners();
        });
      },
    ));
  }
}

void handlePackageRouting(BuildContext context, String notificationId, int packageId) {
  NetworkManager.instance.markNotificationAsRead(notificationId: int.parse(notificationId)).then((value) {
    if (value is OPBaseResponse) {
      Provider.of<CurrentUser>(context, listen: false).getUnreadNotifications();
    }
  });
  NetworkManager.instance.getPackageDetails(packageId: packageId).then(
    (response) async {
      if (response is PudoPackage) {
        if (response.packageStatus == PackageStatus.notifySent) {
          await NetworkManager.instance.changePackageStatus(packageId: response.packageId, newStatus: PackageStatus.notified).then((value) {
            if (value is PudoPackage) {
              Navigator.of(context).pushNamed(Routes.packagePickup, arguments: value).then(
                    (value) => Provider.of<CurrentUser>(context, listen: false).triggerReload(),
                  );
            } else {
              SAAlertDialog.displayAlertWithClose(
                context,
                "genericErrorTitle".localized(context, 'general'),
                value,
                barrierDismissable: false,
              );
            }
          }).catchError((onError) {
            SAAlertDialog.displayAlertWithClose(
              context,
              "genericErrorTitle".localized(context, 'general'),
              onError,
              barrierDismissable: false,
            );
          });
        } else {
          Navigator.of(context).pushNamed(Routes.packagePickup, arguments: response).then((value) => Provider.of<CurrentUser>(context, listen: false).triggerReload());
        }
      } else {
        SAAlertDialog.displayAlertWithClose(
          context,
          "genericErrorTitle".localized(context, 'general'),
          "genericErrorDescription".localized(context, 'general'),
        );
      }
    },
  ).catchError(
    (onError) => SAAlertDialog.displayAlertWithClose(context, "genericErrorTitle".localized(context, 'general'), onError),
  );
}

void handleUserRouting(BuildContext context, String notificationId, int userId) {
  NetworkManager.instance.markNotificationAsRead(notificationId: int.parse(notificationId)).then((value) {
    if (value is OPBaseResponse) {
      Provider.of<CurrentUser>(context, listen: false).getUnreadNotifications();
    }
  });
  NetworkManager.instance.getUserProfile(userId: userId).then(
    (response) async {
      if (response is UserProfile) {
        Navigator.of(context).pushNamed(Routes.userDetail, arguments: response);
      } else {
        SAAlertDialog.displayAlertWithClose(
          context,
          "genericErrorTitle".localized(context, 'general'),
          "genericErrorDescription".localized(context, 'general'),
        );
      }
    },
  ).catchError(
    (onError) => SAAlertDialog.displayAlertWithClose(context, "genericErrorTitle".localized(context, 'general'), onError),
  );
}
