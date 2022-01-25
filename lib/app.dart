//
//  main.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/ui/base_theme.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/commons/utilities/routes.dart';
import 'package:qui_green/resources/app_config.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier currentRouteName = ValueNotifier('/');

void mainCommon({required String host, required bool isProd}) async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString('languagePref', 'it');
  PackageInfo info = await PackageInfo.fromPlatform();

  AppConfig appConfig = AppConfig(
      isProd: isProd,
      host: host,
      appInfo: info,
      sharedPreferencesInstance: sharedPreferences);
  NetworkManager(config: appConfig);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.bottom]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: ThemeData.light().scaffoldBackgroundColor,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(App(
    config: appConfig,
  ));
  //print(NetworkManager.instance.accessToken);
  //NetworkManager.instance.login(login: "+39328000001", password: "6732");
}

class App extends StatelessWidget {
  final AppConfig config;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  App({Key? key, required this.config}) : super(key: key);

  // checkRedirect uses two booleans to intercept changes in the user status (logged or not)
  // if the user is logged navigates the app to the home route
  // if the user is not logged navigates the app to the login route
  void checkRedirect(CurrentUser currentUser) {
    if (currentUser.fetchOnOpenApp && !currentUser.firstNavigationDone) {
      if (currentUser.user == null) {
        navigatorKey.currentState?.pushReplacementNamed(Routes.login);
        currentUser.firstNavigationDone = true;
      } else {
        navigatorKey.currentState?.pushReplacementNamed(Routes.home);
        currentUser.firstNavigationDone = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => CurrentUser(config.sharedPreferencesInstance)),
      ],
      child: Consumer<CurrentUser>(
        builder: (context, currentUser, _) {
          currentUser.navigatorKey = navigatorKey;
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Qui Green',
            supportedLocales: const [
              Locale('en'),
              Locale('it'),
              Locale('de'),
              Locale('es'),
              Locale('fr')
            ],
            localizationsDelegates: [
              LocalizationManagerDelegate(config.sharedPreferencesInstance!),
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            theme: MyAppTheme.themeData(context),
            darkTheme: MyAppTheme.darkThemeData(context),
            initialRoute: "/",
            onGenerateRoute: (settings) {
              return routeWithSetting(settings);
            },
          );
        },
      ),
    );
  }
}
