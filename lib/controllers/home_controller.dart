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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qui_green/commons/utilities/home_user_packages_section_routes.dart';
import 'package:qui_green/commons/utilities/home_user_pudo_section_routes.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class HomeController extends StatefulWidget {
  const HomeController({Key? key}) : super(key: key);

  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> with ConnectionAware {
  int _oldIndex = 0;
  final List<NavigatorObserver> _navigatorObservers = [];

  @override
  void initState() {
    super.initState();
    _navigatorObservers.add(NavigatorObserver());
    _navigatorObservers.add(NavigatorObserver());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          onTap: (selectedIndex) {
            if (selectedIndex == _oldIndex) {
              _navigatorObservers[selectedIndex].navigator?.popUntil((Route<dynamic> route) => route.isFirst);
            }
            _oldIndex = selectedIndex;
          },
          items: [
            BottomNavigationBarItem(
                icon: SvgPicture.asset(ImageSrc.homeArt, color: Colors.grey.shade400), activeIcon: SvgPicture.asset(ImageSrc.homeArt, color: AppColors.primaryColorDark), label: 'Home'),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(ImageSrc.mapsArt, color: Colors.grey.shade400), activeIcon: SvgPicture.asset(ImageSrc.mapsArt, color: AppColors.primaryColorDark), label: 'Pudo'),
          ],
        ),
        tabBuilder: (innerContext, index) {
          switch (index) {
            case 1:
              return CupertinoTabView(
                navigatorObservers: [_navigatorObservers[1]],
                onGenerateRoute: (RouteSettings settings) => routeHomeUserPudoSectionWithSetting(settings),
              );
            default:
              return CupertinoTabView(
                navigatorObservers: [_navigatorObservers[0]],
                onGenerateRoute: (RouteSettings settings) => routeHomeUserPackagesSectionWithSetting(settings),
              );
          }
        },
      ),
    );
  }
}
