//
//  routes.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qui_green/controllers/about_you_controller.dart';
import 'package:qui_green/controllers/confirm_phone_controller.dart';
import 'package:qui_green/controllers/insert_phone_controller.dart';
import 'package:qui_green/controllers/login_controller.dart';
import 'package:qui_green/controllers/user_position_controller.dart';
import '../controllers/home_controller.dart';
import '../main.dart';

dynamic routeWithSetting(RouteSettings settings) {
  log("current route name: ${settings.name}");
  //var analyticsScreenName = settings.name == "/" ? "/login" : settings.name;
  //analyticsInstance.setCurrentScreen(screenName: analyticsScreenName);
  currentRouteName.value = settings.name ?? '/main';
  // if (settings.arguments != null) {
  //   var arguments = settings.arguments;
  // }
  switch (settings.name) {
    // case '/notificationDetails':
    //   return MaterialPageRoute(
    //     builder: (context) => NotificationDetailsController(arguments: settings.arguments),
    //   );
    case '/login':
      return MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const LoginController(),
      );
    case '/insertPhone':
      return MaterialPageRoute(
        builder: (context) => const InsertPhoneController(),
      );
    case '/confirmPhone':
      return MaterialPageRoute(
        builder: (context) => const ConfirmPhoneController(),
      );
    case '/aboutYou':
      return MaterialPageRoute(
        builder: (context) => const AboutYouController(),
      );
    case '/userPosition':
      return MaterialPageRoute(
        builder: (context) => const UserPositionController(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const HomeController(),
      );
  }
}
