//
//  routes.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:qui_green/app.dart';
import 'package:qui_green/controllers/auth/pages/about_you_controller.dart';
import 'package:qui_green/controllers/auth/pages/confirm_phone_controller.dart';
import 'package:qui_green/controllers/exchange/pages/exchange_controller.dart';
import 'package:qui_green/controllers/home/pages/home_controller.dart';
import 'package:qui_green/controllers/auth/pages/insert_phone_controller.dart';
import 'package:qui_green/controllers/auth/pages/login_controller.dart';
import 'package:qui_green/controllers/insert_address/pages/insert_address_controller.dart';
import 'package:qui_green/controllers/instruction/pages/instruction_controller.dart';
import 'package:qui_green/controllers/maps/pages/maps_controller.dart';
import 'package:qui_green/controllers/personal_data/pages/personal_data_controller.dart';
import 'package:qui_green/controllers/personal_data_business/pages/personal_data_business_controller.dart';
import 'package:qui_green/controllers/pudo_detail/pages/pudo_detail_controller.dart';
import 'package:qui_green/controllers/registration_complete/pages/registration_complete_controller.dart';
import 'package:qui_green/controllers/thanks/pages/thanks_controller.dart';
import 'package:qui_green/controllers/user_position/pages/user_position_controller.dart';
import 'package:qui_green/resources/routes_enum.dart';

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
    case Routes.login:
      return CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => const LoginController(),
      );
    case Routes.insertPhone:
      return CupertinoPageRoute(
        builder: (context) => const InsertPhoneController(),
      );
    case Routes.confirmPhone:
      return CupertinoPageRoute(
        builder: (context) => const ConfirmPhoneController(),
      );
    case Routes.aboutYou:
      return CupertinoPageRoute(
        builder: (context) => const AboutYouController(),
      );
    case Routes.userPosition:
      return CupertinoPageRoute(
        builder: (context) => const UserPositionController(),
      );
    case Routes.insertAddress:
      return CupertinoPageRoute(
        builder: (context) => const InsertAddressController(),
      );
    case Routes.maps:
      return CupertinoPageRoute(
        builder: (context) => const MapsController(),
      );
    case Routes.pudoDetail:
      return CupertinoPageRoute(
        builder: (context) => const PudoDetailController(),
      );
    case Routes.personalData:
      return CupertinoPageRoute(
        builder: (context) => const PersonalDataController(),
      );
    case Routes.registrationComplete:
      return CupertinoPageRoute(
        builder: (context) => const RegistrationCompleteController(),
      );
    case Routes.instruction:
      return CupertinoPageRoute(
        builder: (context) => const InstructionController(),
      );
    case Routes.thanks:
      return CupertinoPageRoute(
        builder: (context) => const ThanksController(),
      );
    case Routes.personalDataBusiness:
      return CupertinoPageRoute(
        builder: (context) => const PersonalDataBusinessController(),
      );
    case Routes.exchange:
      return CupertinoPageRoute(
        builder: (context) => const ExchangeController(),
      );
    // case Routes.pudoTutorial:
    //   return CupertinoPageRoute(
    //     builder: (context) => const PudoTutorialController(),
    //   );
    default:
      return CupertinoPageRoute(
        builder: (context) => const HomeController(),
      );
  }
}
