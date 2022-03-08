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
import 'package:qui_green/app.dart';
import 'package:qui_green/commons/utilities/analytics_helper.dart';
import 'package:qui_green/commons/utilities/page_route_helper.dart';
import 'package:qui_green/controllers/error_controller.dart';
import 'package:qui_green/controllers/notify_sent_controller.dart';
import 'package:qui_green/controllers/onboarding/pudo_profile_edit_controller.dart';
import 'package:qui_green/controllers/package_delivered_controller.dart';
import 'package:qui_green/controllers/package_pickup_controller.dart';
import 'package:qui_green/controllers/package_received_controller.dart';
import 'package:qui_green/controllers/packages_list_controller.dart';
import 'package:qui_green/controllers/pudo_users_list_controller.dart';
import 'package:qui_green/controllers/user_detail_controller.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';

dynamic homePudoRouteWithSetting(RouteSettings settings) {
  log("current route name: ${settings.name}");
  currentRouteName.value = settings.name ?? '/main';
  if (settings.name != "/") {
    AnalyticsHelper.logPageChange(settings.name ?? '/mainPudo');
  }
  switch (settings.name) {
    case Routes.profileEdit:
      return PageRouteHelper.buildPage(const PudoProfileEditController(
        isOnHome: true,
      ));
    case Routes.userDetail:
      return PageRouteHelper.buildPage(UserDetailController(userModel: settings.arguments as UserProfile));
    case Routes.packagePickup:
      return PageRouteHelper.buildPage(PackagePickupController(
        packageModel: settings.arguments as PudoPackage,
        isForPudo: true,
      ));
    case Routes.packagesListWithHistory:
      return PageRouteHelper.buildPage(
        const PackagesListController(
          isForPudo: true,
          isOnReceivePack: false,
          enableHistory: true,
        ),
      );
    case Routes.packagesList:
      return PageRouteHelper.buildPage(
        const PackagesListController(
          isForPudo: true,
          enableHistory: false,
          isOnReceivePack: true,
        ),
      );
    case Routes.notifySent:
      return PageRouteHelper.buildPage(
        NotifySentController(username: settings.arguments as String),
      );
    case Routes.pudoUsersList:
      return PageRouteHelper.buildPage(
        const PudoUsersListController(),
      );
    case Routes.searchRecipient:
      return PageRouteHelper.buildPage(
        const PudoUsersListController(
          isOnReceivePack: true,
        ),
      );
    case Routes.packageReceived:
      return PageRouteHelper.buildPage(
        const PackageReceivedController(),
      );
    case Routes.packageDelivered:
      return PageRouteHelper.buildPage(
        const PackageDeliveredController(),
      );
    default:
      return PageRouteHelper.buildPage(
        const ErrorController(),
      );
  }
}
