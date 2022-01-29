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

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:qui_green/app.dart';
import 'package:qui_green/controllers/about_you_controller.dart';
import 'package:qui_green/controllers/onboarding/confirm_phone_controller.dart';
import 'package:qui_green/controllers/onboarding/exchange_controller.dart';
import 'package:qui_green/controllers/home_controller.dart';
import 'package:qui_green/controllers/home_pudo_controller.dart';
import 'package:qui_green/controllers/onboarding/insert_address_controller.dart';
import 'package:qui_green/controllers/onboarding/insert_phone_controller.dart';
import 'package:qui_green/controllers/instruction_controller.dart';
import 'package:qui_green/controllers/pudo_home_controller.dart';
import 'package:qui_green/controllers/pudo_list_controller.dart';
import 'package:qui_green/controllers/onboarding/login_controller.dart';
import 'package:qui_green/controllers/maps_controller.dart';
import 'package:qui_green/controllers/onboarding/personal_data_controller.dart';
import 'package:qui_green/controllers/onboarding/personal_data_business_controller.dart';
import 'package:qui_green/controllers/profile_controller.dart';
import 'package:qui_green/controllers/thanks_controller.dart';
import 'package:qui_green/models/pudo_detail_controller_data_model.dart';
import 'package:qui_green/controllers/pudo_detail_controller.dart';
import 'package:qui_green/controllers/pudo_tutorial_controller.dart';
import 'package:qui_green/controllers/registration_complete_controller.dart';
import 'package:qui_green/controllers/user_position_controller.dart';
import 'package:qui_green/models/pudo_profile.dart';
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
        builder: (context) => ConfirmPhoneController(
          phoneNumber: settings.arguments as String,
        ),
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
        builder: (context) =>
            MapsController(initialPosition: settings.arguments as LatLng),
      );
    case Routes.pudoDetail:
      return CupertinoPageRoute(
        builder: (context) => PudoDetailController(
            dataModel: settings.arguments as PudoDetailControllerDataModel),
      );
    case Routes.personalData:
      return CupertinoPageRoute(
        builder: (context) => PersonalDataController(
            pudoDataModel: settings.arguments == null
                ? null
                : settings.arguments as PudoProfile),
      );
    case Routes.registrationComplete:
      return CupertinoPageRoute(
        builder: (context) => RegistrationCompleteController(
            pudoDataModel: settings.arguments == null
                ? null
                : settings.arguments as PudoProfile),
      );
    case Routes.instruction:
      return CupertinoPageRoute(
        builder: (context) => InstructionController(
            pudoDataModel: settings.arguments == null
                ? PudoProfile(businessName: "Nome Pudo")
                : settings.arguments as PudoProfile),
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
    case Routes.pudoTutorial:
      return CupertinoPageRoute(
        builder: (context) => const PudoTutorialController(),
      );
    case Routes.homePudo:
      return CupertinoPageRoute(
        builder: (context) => const HomePudoController(),
      );
    case Routes.profile:
      return CupertinoPageRoute(
        builder: (context) => const ProfileController(),
      );
    case Routes.pudoList:
      return CupertinoPageRoute(
        builder: (context) => const PudoListController(),
      );
    case Routes.home:
      return CupertinoPageRoute(
        builder: (context) => const HomeController(),
      );
    case Routes.pudoHome:
      return CupertinoPageRoute(
          builder: (context) => const PudoHomeController());
    default:
      return CupertinoPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
  }
}
