/*
 OpenPUDO - PUDO and Micro-delivery software for Last Mile Collaboration
 Copyright (C) 2020-2022 LESS SRL - https://less.green

 This file is part of OpenPUDO software.

 OpenPUDO is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License version 3
 as published by the Copyright Owner.

 OpenPUDO is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License version 3 for more details.

 You should have received a copy of the GNU Affero General Public License
 version 3 published by the Copyright Owner along with OpenPUDO.  
 If not, see <https://github.com/lessgreen/OpenPUDO>.
*/

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/ui/base_theme.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/commons/utilities/print_helper.dart';
import 'package:qui_green/commons/utilities/routes.dart';
import 'package:qui_green/resources/app_config.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier currentRouteName = ValueNotifier('/');
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  safePrint('Handling a background message ${message.messageId}');
  safePrint(message.data);
}

void mainCommon({required String host, required bool isProd}) async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString('languagePref', 'it');
  PackageInfo info = await PackageInfo.fromPlatform();

  AppConfig appConfig = AppConfig(isProd: isProd, host: host, appInfo: info, sharedPreferencesInstance: sharedPreferences);
  NetworkManager(config: appConfig);
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.bottom],
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: ThemeData.light().scaffoldBackgroundColor,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //Firebase stuff
  await Firebase.initializeApp();
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails? lunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (lunchDetails != null) {
    safePrint(lunchDetails.payload ?? "");
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
  runApp(
    App(
      config: appConfig,
    ),
  );
}

class App extends StatelessWidget {
  final AppConfig config;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  App({Key? key, required this.config}) : super(key: key);

  // checkRedirect uses two booleans to intercept changes in the user status (logged or not)
  // if the user is logged navigates the app to the home route
  // if the user is not logged navigates the app to the login route

  void pushPage(String route) => navigatorKey.currentState?.pushNamedAndRemoveUntil(
        route,
        ModalRoute.withName('/'),
      );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrentUser(config.sharedPreferencesInstance, pushPage: pushPage)),
      ],
      child: Consumer<CurrentUser>(
        builder: (context, currentUser, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Qui Green',
            supportedLocales: const [
              Locale('en'),
              Locale('it'),
              Locale('de'),
              Locale('es'),
              Locale('fr'),
            ],
            localizationsDelegates: [
              LocalizationManagerDelegate(config.sharedPreferencesInstance!),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            theme: MyAppTheme.themeData(context),
            darkTheme: MyAppTheme.themeData(context),
            initialRoute: NetworkManager.instance.accessToken.isEmpty ? Routes.login : "/",
            onGenerateRoute: (settings) {
              return routeWithSetting(settings);
            },
          );
        },
      ),
    );
  }
}
