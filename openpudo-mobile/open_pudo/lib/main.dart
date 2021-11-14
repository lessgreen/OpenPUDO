//
//  main.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/singletons/current_user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:open_pudo/commons/color_serializer.dart';

import 'controllers/routes.dart';

SharedPreferences? sharedPreferences;
Location location = new Location();
String currentRouteName = '/';
ValueNotifier needsLogin = ValueNotifier(false);
ValueNotifier badgeCounter = ValueNotifier(0);

PackageInfo packageInfo = PackageInfo(
  appName: 'Unknown',
  packageName: 'Unknown',
  version: 'Unknown',
  buildNumber: 'Unknown',
);
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;

/// Define a top-level named handler which background/terminated messages will call.
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences?.setString('languagePref', 'it');
  packageInfo = await PackageInfo.fromPlatform();

  //Firebase stuff
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
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

  // FlutterAppBadger.isAppBadgeSupported().then((value) {
  //   if (value == true) {
  //     FlutterAppBadger.removeBadge();
  //   }
  // });

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ));
  });
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  void rebuild() {
    rebuildAllChildren(context);
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      LocalizationManager.preloadLocale(Localizations.localeOf(context)).then((aManager) {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    needsLogin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.bottom]).then((value) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    });
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrentUser()),
      ],
      child: Consumer<CurrentUser>(
        builder: (context, currentUser, _) {
          // if (currentUser != null && currentUser.user != null) {
          //   NetworkManager().setAccessToken(currentUser.user.accesstoken);
          // } else {
          //   NetworkManager().setAccessToken(null);
          //   if (rootNavigatorKey.currentState != null && rootNavigatorKey.currentState.widget.initialRoute != '/') {
          //     rootNavigatorKey.currentState.pushNamedAndRemoveUntil('/', (route) => false);
          //   }
          // }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: [const Locale('en'), const Locale('it'), const Locale('de'), const Locale('es'), const Locale('fr')],
            localizationsDelegates: [
              LocalizationManagerDelegate(sharedPreferences!),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Color(0xff95C11F).materialColor,
                primaryColor: Color(0xff95C11F).materialColor,
                primaryColorBrightness: Brightness.dark,
                backgroundColor: Colors.white),
            initialRoute: '/',
            onGenerateRoute: ((RouteSettings settings) {
              return routeWithSetting(settings);
            }),
            builder: (context, child) {
              //var currentTextScaleFactor = MediaQuery.of(context).textScaleFactor;
              return MediaQuery(
                child: child!,
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              );
            },
          );
        },
      ),
    );
  }
}
