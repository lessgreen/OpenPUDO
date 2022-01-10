//
//  main.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/ui/base_theme.dart';
import 'package:qui_green/commons/utilities/routes.dart';
import 'package:qui_green/singletons/network.dart';

ValueNotifier currentRouteName = ValueNotifier('/');

void mainCommon({required String host, required bool isProd}) async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      App(isProd: isProd, host: host),
    ),
  );
}

class App extends StatelessWidget {
  final String host;
  final bool isProd;

  const App({Key? key, required this.host, required this.isProd})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NetworkManager>(
          create: (context) => NetworkManager(host: host, isProd: isProd),
        ),
      ],
      child: Consumer(
        builder: (context, currentUser, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Qui Green',
            theme: MyAppTheme.themeData(context),
            darkTheme: MyAppTheme.darkThemeData(context),
            initialRoute: '/insertPhone',
            onGenerateRoute: (settings) {
              return routeWithSetting(settings);
            },
          );
        },
      ),
    );
  }
}
