//
//  main.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qui_green/commons/color_serializer.dart';
import 'package:qui_green/commons/routes.dart';

ValueNotifier currentRouteName = ValueNotifier('/');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qui Green',
      theme: ThemeData(
        textTheme: TextTheme(
          headline1: Theme.of(context).textTheme.headline1?.copyWith(letterSpacing: 0.7),
          headline2: Theme.of(context).textTheme.headline2?.copyWith(letterSpacing: 0.7),
          headline3: Theme.of(context).textTheme.headline3?.copyWith(letterSpacing: 0.7),
          headline4: Theme.of(context).textTheme.headline4?.copyWith(letterSpacing: 0.7),
          headline5: Theme.of(context).textTheme.headline5?.copyWith(letterSpacing: 0.7),
          headline6: Theme.of(context).textTheme.headline6?.copyWith(letterSpacing: 0.7),
          subtitle1: Theme.of(context).textTheme.subtitle1?.copyWith(letterSpacing: 0.7),
          subtitle2: Theme.of(context).textTheme.subtitle2?.copyWith(letterSpacing: 0.7),
          bodyText1: Theme.of(context).textTheme.bodyText1?.copyWith(letterSpacing: 0.7),
          bodyText2: Theme.of(context).textTheme.bodyText2?.copyWith(letterSpacing: 0.7),
          button: Theme.of(context).textTheme.button?.copyWith(letterSpacing: 0.7),
          caption: Theme.of(context).textTheme.caption?.copyWith(letterSpacing: 0.7),
          overline: Theme.of(context).textTheme.overline?.copyWith(letterSpacing: 0.7),
        ),
        primarySwatch: const Color(0xFFA0B92C).materialColor,
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch(
          accentColor: const Color(0xFFA0B92C).materialColor,
          cardColor: const Color(0xFFA0B92C).materialColor,
          primaryColorDark: const Color(0xFFA0B92C).materialColor,
          primarySwatch: const Color(0xFFA0B92C).materialColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark), // 2
        ),
        buttonTheme: ButtonThemeData(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.white), // Text color
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(foregroundColor: Colors.white, elevation: 0),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: const Color(0xFFA0B92C).materialColor,
        colorScheme: ColorScheme.fromSwatch(
          accentColor: const Color(0xFFA0B92C).materialColor,
          cardColor: const Color(0xFFA0B92C).materialColor,
          primaryColorDark: const Color(0xFFA0B92C).materialColor,
          primarySwatch: const Color(0xFFA0B92C).materialColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark), // 2
        ),
        buttonTheme: ButtonThemeData(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.white), // Text color
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(foregroundColor: Colors.white, elevation: 0),
      ),
      initialRoute: '/insertPhone',
      onGenerateRoute: (settings) {
        return routeWithSetting(settings);
      },
    );
  }
}
