//
//  routes.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 02/07/2021.
//  Copyright © 2021 Sofapps. All rights reserved.

import 'package:flutter/material.dart';
import 'package:open_pudo/controllers/business_pudo_profile_controller.dart';
import 'package:open_pudo/controllers/edit_user_profile_controller.dart';
import 'package:open_pudo/controllers/login_controller.dart';
import 'package:open_pudo/controllers/my_packages_controller.dart';
import 'package:open_pudo/controllers/my_pudos_controller.dart';
import 'package:open_pudo/controllers/notification_details_controller.dart';
import 'package:open_pudo/controllers/notifications_controller.dart';
import 'package:open_pudo/controllers/package_addnote_controller.dart';
import 'package:open_pudo/controllers/package_selectuser_controller.dart';
import 'package:open_pudo/controllers/public_pudo_profile_controller.dart';
import 'package:open_pudo/controllers/registration_controller.dart';
import 'package:open_pudo/controllers/splash_intro_controller.dart';
import 'package:open_pudo/controllers/success_package_controller.dart';
import 'package:open_pudo/controllers/update_package_controller.dart';
import '../main.dart';
import 'edit_business_profile_controller.dart';
import 'home_controller.dart';

dynamic routeWithSetting(RouteSettings settings) {
  print("current route name: ${settings.name}");
  //var analyticsScreenName = settings.name == "/" ? "/login" : settings.name;
  //analyticsInstance.setCurrentScreen(screenName: analyticsScreenName);
  currentRouteName = settings.name ?? '/main';
  // if (settings.arguments != null) {
  //   var arguments = settings.arguments;
  // }
  switch (settings.name) {
    case '/successPackage':
      return MaterialPageRoute(
        builder: (context) => SuccessPackageController(),
      );
    case '/packageAddNote':
      return MaterialPageRoute(
        builder: (context) => PackageAddNoteController(),
      );
    case '/packageSelectUser':
      return MaterialPageRoute(
        builder: (context) => PackageSelectUserController(),
      );
    case '/updatePackage':
      return MaterialPageRoute(
        builder: (context) => UpdatePackageController(),
        fullscreenDialog: true,
      );
    case '/notificationDetails':
      return MaterialPageRoute(
        builder: (context) => NotificationDetailsController(arguments: settings.arguments),
      );
    case '/myNotifications':
      return MaterialPageRoute(
        builder: (context) => NotificationsController(),
        fullscreenDialog: true,
      );
    case '/myPackages':
      return MaterialPageRoute(
        builder: (context) => MyPackagesController(),
      );
    case '/myPudos':
      return MaterialPageRoute(
        builder: (context) => MyPudosController(),
      );
    case '/login':
      return MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => LoginController(),
      );
    case '/registration':
      return MaterialPageRoute(
        builder: (context) => RegistrationController(),
      );
    case '/editUserProfile':
      return MaterialPageRoute(
        builder: (context) => EditUserProfileController(),
      );
    case '/editBusinessProfile':
      return MaterialPageRoute(
        builder: (context) => EditBusinessProfileController(),
      );
    case "/publicPudoProfile":
      return MaterialPageRoute(
        builder: (context) => PublicPudoProfileController(arguments: settings.arguments),
      );
    case "/myBusinessProfile":
      return MaterialPageRoute(
        builder: (context) => BusinessPudoProfileController(arguments: settings.arguments),
      );
    case "/onboarding":
      return MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => SplashIntroController(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => HomeController(),
      );
  }
}
