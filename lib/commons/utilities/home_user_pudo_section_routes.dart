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
import 'package:latlong2/latlong.dart';
import 'package:qui_green/app.dart';
import 'package:qui_green/controllers/instruction_controller.dart';
import 'package:qui_green/controllers/onboarding/insert_address_controller.dart';
import 'package:qui_green/controllers/onboarding/maps_controller.dart';
import 'package:qui_green/controllers/profile_controller.dart';
import 'package:qui_green/controllers/pudo_detail_controller.dart';
import 'package:qui_green/controllers/pudo_list_controller.dart';
import 'package:qui_green/controllers/pudo_tutorial_controller.dart';
import 'package:qui_green/controllers/registration_complete_controller.dart';
import 'package:qui_green/controllers/user_position_controller.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';

dynamic routeHomeUserPudoSectionWithSetting(RouteSettings settings) {
  log("current route name: ${settings.name}");
  currentRouteName.value = settings.name ?? '/main';
  switch (settings.name) {
    case Routes.instruction:
      return CupertinoPageRoute(
        builder: (context) => InstructionController(
          pudoDataModel: settings.arguments as PudoProfile?,
          useCupertinoScaffold: true,
          canGoBack: true,
        ),
      );
    case Routes.registrationComplete:
      return CupertinoPageRoute(
        builder: (context) => RegistrationCompleteController(
          pudoDataModel: settings.arguments as PudoProfile,
          useCupertinoScaffold: true,
          canGoBack: true,
        ),
      );
    case Routes.maps:
      return CupertinoPageRoute(
        builder: (context) => MapsController(
          canGoBack: true,
          initialPosition: settings.arguments as LatLng,
          useCupertinoScaffold: true,
          enableAddressSearch: false,
          enablePudoCards: true,
          getUserPosition: false,
          canOpenProfilePage: false,
          title: "Seleziona un pudo",
        ),
      );
    case Routes.insertAddress:
      return CupertinoPageRoute(
        builder: (context) => const InsertAddressController(
          useCupertinoScaffold: true,
        ),
      );
    case Routes.userPosition:
      return CupertinoPageRoute(
        builder: (context) => const UserPositionController(
          canGoBack: true,
          useCupertinoScaffold: true,
        ),
      );
    case Routes.pudoTutorial:
      return CupertinoPageRoute(
        builder: (context) => const PudoTutorialController(),
      );
    case Routes.profile:
      return CupertinoPageRoute(
        builder: (context) => const ProfileController(),
      );
    case Routes.pudoDetail:
      return CupertinoPageRoute(
        builder: (context) => PudoDetailController(
          useCupertinoScaffold: true,
          dataModel: settings.arguments as PudoProfile,
          checkIsAlreadyAdded: true,
        ),
      );
    case Routes.pudoList:
      return CupertinoPageRoute(builder: (context) => const PudoListController());
    default:
      return CupertinoPageRoute(
        builder: (context) => const MapsController(
          canGoBack: false,
          useCupertinoScaffold: true,
          enableAddressSearch: true,
          enablePudoCards: false,
          getUserPosition: true,
          canOpenProfilePage: true,
          title: "QuiGreen",
        ),
      );
  }
}
