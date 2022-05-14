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

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:qui_green/app.dart';
import 'package:qui_green/commons/utilities/analytics_helper.dart';
import 'package:qui_green/commons/utilities/page_route_helper.dart';
import 'package:qui_green/controllers/about_you_controller.dart';
import 'package:qui_green/controllers/home_controller.dart';
import 'package:qui_green/controllers/instruction_controller.dart';
import 'package:qui_green/controllers/onboarding/confirm_phone_controller.dart';
import 'package:qui_green/controllers/onboarding/insert_address_controller.dart';
import 'package:qui_green/controllers/onboarding/insert_phone_controller.dart';
import 'package:qui_green/controllers/onboarding/login_controller.dart';
import 'package:qui_green/controllers/onboarding/map_controller.dart';
import 'package:qui_green/controllers/onboarding/personal_data_business_controller.dart';
import 'package:qui_green/controllers/onboarding/personal_data_controller.dart';
import 'package:qui_green/controllers/onboarding/pudo_profile_edit_controller.dart';
import 'package:qui_green/controllers/onboarding/reward_policy_controller.dart';
import 'package:qui_green/controllers/pudo_detail_controller.dart';
import 'package:qui_green/controllers/pudo_home_controller.dart';
import 'package:qui_green/controllers/pudo_list_controller.dart';
import 'package:qui_green/controllers/registration_complete_controller.dart';
import 'package:qui_green/controllers/thanks_controller.dart';
import 'package:qui_green/controllers/user_position_controller.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/registration_pudo_model.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

dynamic routeWithSetting(RouteSettings settings) {
  log("current route name: ${settings.name}");
  //var analyticsScreenName = settings.name == "/" ? "/login" : settings.name;
  //analyticsInstance.setCurrentScreen(screenName: analyticsScreenName);
  currentRouteName.value = settings.name ?? '/main';
  // if (settings.arguments != null) {
  //   var arguments = settings.arguments;
  // }
  if (settings.name != "/") {
    AnalyticsHelper.logPageChange((settings.name ?? 'main').replaceAll("/", ""));
  }
  switch (settings.name) {
    // case '/notificationDetails':
    //   return MaterialPageRoute(
    //     builder: (context) => NotificationDetailsController(arguments: settings.arguments),
    //   );
    case Routes.login:
      return PageRouteHelper.buildPage(
        const LoginController(),
      );
    case Routes.insertPhone:
      return PageRouteHelper.buildPage(
        const InsertPhoneController(),
      );
    case Routes.confirmPhone:
      return PageRouteHelper.buildPage(
        ConfirmPhoneController(
          phoneNumber: settings.arguments as String,
        ),
      );
    case Routes.aboutYou:
      return PageRouteHelper.buildPage(
        AboutYouController(phoneNumber: settings.arguments as String),
      );
    case Routes.userPosition:
      return PageRouteHelper.buildPage(
        const UserPositionController(
          canGoBack: true,
        ),
      );
    case Routes.insertAddress:
      return PageRouteHelper.buildPage(
        const InsertAddressController(
          useCupertinoScaffold: false,
        ),
      );
    case Routes.maps:
      return PageRouteHelper.buildPage(
        MapController(
          canGoBack: true,
          initialPosition: settings.arguments as LatLng,
          useCupertinoScaffold: false,
          enableAddressSearch: false,
          enablePudoCards: true,
          getUserPosition: false,
          title: 'poiNearbyTitle',
          isOnboarding: false,
        ),
      );
    case Routes.pudoDetail:
      return PageRouteHelper.buildPage(
        PudoDetailController(
          dataModel: settings.arguments as PudoProfile,
          checkIsAlreadyAdded: false,
          nextRoute: Routes.personalData,
          useCupertinoScaffold: false,
        ),
      );
    case Routes.personalData:
      return PageRouteHelper.buildPage(
        PersonalDataController(pudoDataModel: settings.arguments as PudoProfile?),
      );
    case Routes.registrationComplete:
      return PageRouteHelper.buildPage(
        RegistrationCompleteController(
          pudoDataModel: settings.arguments as PudoProfile?,
          canGoBack: false,
          useCupertinoScaffold: false,
        ),
      );
    case Routes.instruction:
      return PageRouteHelper.buildPage(
        InstructionController(
          pudoDataModel: settings.arguments as PudoProfile?,
          useCupertinoScaffold: false,
          canGoBack: false,
        ),
      );
    case Routes.thanks:
      return PageRouteHelper.buildPage(
        const ThanksController(),
      );
    case Routes.pudoRegistrationPreview:
      return PageRouteHelper.buildPage(const PudoProfileEditController(
        isOnHome: false,
      ));
    case Routes.rewardPolicy:
      return PageRouteHelper.buildPage(
        RewardPolicyController(
          pudoRegistrationModel: settings.arguments as RegistrationPudoModel,
        ),
      );
    case Routes.personalDataBusiness:
      return PageRouteHelper.buildPage(
        PersonalDataBusinessController(
          canGoBack: true,
          phoneNumber: settings.arguments as String,
        ),
      );
    case Routes.userPudoTutorial:
      return PageRouteHelper.buildPage(InstructionController(
        canGoBack: false,
        useCupertinoScaffold: false,
        pudoDataModel: settings.arguments as PudoProfile,
      ));
    case Routes.pudoTutorial:
      return PageRouteHelper.buildPage(InstructionController(
        canGoBack: false,
        useCupertinoScaffold: false,
        pudoDataModel: settings.arguments as PudoProfile,
        isForPudo: true,
      ));
    case Routes.pudoList:
      return PageRouteHelper.buildPage(
        const PudoListController(),
      );
    case Routes.home:
      return PageRouteHelper.buildPage(
        const HomeController(),
      );
    case Routes.pudoHome:
      return PageRouteHelper.buildPage(
        const PudoHomeController(),
      );
    default:
      return PageRouteHelper.buildPage(
        Scaffold(
          body: Center(
            child: SvgPicture.asset(
              ImageSrc.launcherIcon,
              width: 120,
              height: 120,
            ),
          ),
        ),
      );
  }
}
