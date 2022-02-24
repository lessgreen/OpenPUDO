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
import 'package:qui_green/controllers/home_user_packages.dart';
import 'package:qui_green/controllers/package_pickup_controller.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/resources/routes_enum.dart';

dynamic routeHomeUserPackagesSectionWithSetting(RouteSettings settings) {
  log("current route name: ${settings.name}");
  currentRouteName.value = settings.name ?? '/main';
  switch (settings.name) {
    case Routes.packagePickup:
      return PageRouteBuilder(
        settings: settings,
        opaque: true,
        transitionDuration: const Duration(milliseconds: 120),
        pageBuilder: (BuildContext context, _, __) {
          return PackagePickupController(packageModel: settings.arguments as PudoPackage);
        },
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return SlideTransition(
            transformHitTests: false,
            child: child,
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
          );
        },
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const HomeUserPackages(),
      );
  }
}
