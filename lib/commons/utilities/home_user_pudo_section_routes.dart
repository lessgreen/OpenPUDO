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
import 'package:qui_green/app.dart';
import 'package:qui_green/commons/utilities/page_route_helper.dart';
import 'package:qui_green/controllers/onboarding/maps_controller.dart';
import 'package:qui_green/controllers/pudo_detail_controller.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';

dynamic routeHomeUserPudoSectionWithSetting(RouteSettings settings) {
  log("current route name: ${settings.name}");
  currentRouteName.value = settings.name ?? '/main';
  switch (settings.name) {
    case Routes.pudoDetail:
      return PageRouteHelper.buildPage(PudoDetailController(
        useCupertinoScaffold: true,
        dataModel: settings.arguments as PudoProfile,
        checkIsAlreadyAdded: true,
      ));
    default:
      return PageRouteHelper.buildPage(
        const MapsController(
          canGoBack: false,
          useCupertinoScaffold: true,
          enableAddressSearch: true,
          enablePudoCards: false,
          getUserPosition: true,
          canOpenProfilePage: false,
          isOnboarding: false,
          title: "QuiGreen",
        ),
      );
  }
}
