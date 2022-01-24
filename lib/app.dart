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
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier currentRouteName = ValueNotifier('/');
SharedPreferences? sharedPreferences;

void mainCommon({required String host, required bool isProd}) async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences?.setString('languagePref', 'it');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      App(isProd: isProd, host: host),
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.bottom]).then((value) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: ThemeData.light().scaffoldBackgroundColor,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  });

  PackageInfo info = await PackageInfo.fromPlatform();
  NetworkManager(
      config: AppConfig(
          isProd: isProd,
          host: host,
          appInfo: info,
          sharedPreferencesInstance: sharedPreferences));

  NetworkManager.instance.login(login: "+39328000001", password: "6732");
}

class App extends StatelessWidget {
  final String host;
  final bool isProd;

  const App({Key? key, required this.host, required this.isProd})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, currentUser, _) {
        return MaterialApp(
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
            LocalizationManagerDelegate(sharedPreferences!),
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          theme: MyAppTheme.themeData(context),
          darkTheme: MyAppTheme.darkThemeData(context),
          initialRoute: Routes.insertPhone,
          onGenerateRoute: (settings) {
            return routeWithSetting(settings);
          },
        );
      },
    );
  }
}
