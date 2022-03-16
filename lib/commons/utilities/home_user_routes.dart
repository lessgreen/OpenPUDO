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
import 'package:qui_green/commons/utilities/page_route_helper.dart';
import 'package:qui_green/controllers/contact_us_controller.dart';
import 'package:qui_green/controllers/error_controller.dart';
import 'package:qui_green/controllers/instruction_controller.dart';
import 'package:qui_green/controllers/onboarding/insert_address_controller.dart';
import 'package:qui_green/controllers/onboarding/map_controller.dart';
import 'package:qui_green/controllers/package_pickup_controller.dart';
import 'package:qui_green/controllers/packages_list_controller.dart';
import 'package:qui_green/controllers/pudo_detail_controller.dart';
import 'package:qui_green/controllers/pudo_list_controller.dart';
import 'package:qui_green/controllers/registration_complete_controller.dart';
import 'package:qui_green/controllers/user_position_controller.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';

dynamic homeUserRouteWithSetting(RouteSettings settings) {
  log("current route name: ${settings.name}");
  currentRouteName.value = settings.name ?? '/main';
  switch (settings.name) {
    case Routes.packagesList:
      return PageRouteHelper.buildPage(const PackagesListController(
        isForPudo: false,
      ));
    case Routes.pudoDetail:
      return PageRouteHelper.buildPage(PudoDetailController(
        useCupertinoScaffold: true,
        dataModel: settings.arguments as PudoProfile,
        checkIsAlreadyAdded: true,
      ));
    case Routes.packagePickup:
      return PageRouteHelper.buildPage(PackagePickupController(packageModel: settings.arguments as PudoPackage));
    case Routes.instruction:
      return PageRouteHelper.buildPage(
        InstructionController(
          pudoDataModel: settings.arguments as PudoProfile?,
          canGoBack: true,
          useCupertinoScaffold: true,
        ),
      );
    case Routes.registrationComplete:
      return PageRouteHelper.buildPage(
        RegistrationCompleteController(
          pudoDataModel: settings.arguments as PudoProfile,
          useCupertinoScaffold: true,
          canGoBack: true,
        ),
      );
    case Routes.maps:
      return PageRouteHelper.buildPage(
        MapController(
          initialPosition: settings.arguments as LatLng,
          canGoBack: true,
          useCupertinoScaffold: true,
          enableAddressSearch: false,
          enablePudoCards: false,
          getUserPosition: false,
          canOpenProfilePage: false,
          title: "Seleziona un pudo",
          isOnboarding: true,
        ),
      );
    case Routes.insertAddress:
      return PageRouteHelper.buildPage(
        const InsertAddressController(
          useCupertinoScaffold: true,
        ),
      );
    case Routes.userPosition:
      return PageRouteHelper.buildPage(
        const UserPositionController(
          canGoBack: true,
          useCupertinoScaffold: true,
        ),
      );
    case Routes.pudoTutorial:
      return PageRouteHelper.buildPage(
        InstructionController(
          canGoBack: true,
          useCupertinoScaffold: true,
          pudoDataModel: settings.arguments as PudoProfile,
        ),
      );
    case Routes.pudoDetailOnBoarding:
      return PageRouteHelper.buildPage(
        PudoDetailController(
          dataModel: settings.arguments as PudoProfile,
          nextRoute: Routes.registrationComplete,
          checkIsAlreadyAdded: true,
          useCupertinoScaffold: true,
        ),
      );
    case Routes.pudoList:
      return PageRouteHelper.buildPage(
        const PudoListController(),
      );
    case Routes.contactUs:
      return PageRouteHelper.buildPage(
        const ContactUsController(),
      );
    default:
      return PageRouteHelper.buildPage(
        const ErrorController(),
      );
  }
}
