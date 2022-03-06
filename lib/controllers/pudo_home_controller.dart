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
import 'package:move_to_background/move_to_background.dart';
import 'package:qui_green/commons/ui/tab_controller_container.dart';
import 'package:qui_green/commons/utilities/home_pudo_routes.dart';
import 'package:qui_green/controllers/pudo_main_controller.dart';
import 'package:qui_green/controllers/pudo_profile_controller.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class PudoHomeController extends StatefulWidget {
  const PudoHomeController({Key? key}) : super(key: key);

  @override
  _PudoHomeControllerState createState() => _PudoHomeControllerState();
}

class _PudoHomeControllerState extends State<PudoHomeController> with ConnectionAware {
  int _oldIndex = 0;
  final CupertinoTabController _tabController = CupertinoTabController();
  List<TabControllerContainer> _controllers = [];

  @override
  void initState() {
    super.initState();
    _controllers = [
      TabControllerContainer(
        tabView: CupertinoTabView(
          navigatorKey: GlobalKey(),
          builder: (context) => const PudoMainController(),
          onGenerateRoute: (RouteSettings settings) => homePudoRouteWithSetting(settings),
        ),
        bottomView: BottomNavigationBarItem(
          icon: SvgPicture.asset(ImageSrc.homeArt, color: Colors.grey.shade400),
          activeIcon: SvgPicture.asset(ImageSrc.homeArt, color: AppColors.primaryColorDark),
          label: 'Home',
        ),
      ),
      TabControllerContainer(
        tabView: CupertinoTabView(
          navigatorKey: GlobalKey(),
          builder: (context) => const PudoProfileController(),
          onGenerateRoute: (RouteSettings settings) => homePudoRouteWithSetting(settings),
        ),
        bottomView: BottomNavigationBarItem(
          icon: SvgPicture.asset(ImageSrc.profileArt, color: Colors.grey.shade400),
          activeIcon: SvgPicture.asset(ImageSrc.profileArt, color: AppColors.primaryColorDark),
          label: 'Profile',
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: WillPopScope(
        onWillPop: () async {
          var currentIndex = _tabController.index;
          var currentTab = _controllers[currentIndex].tabView;
          var currentContext = currentTab.navigatorKey?.currentContext;
          if (currentContext != null) {
            if (Navigator.of(currentContext).canPop()) {
              return !await Navigator.of(currentContext).maybePop();
            }
          }
          MoveToBackground.moveTaskToBack();
          return false;
        },
        child: CupertinoTabScaffold(
          controller: _tabController,
          tabBar: CupertinoTabBar(
            onTap: (selectedIndex) {
              if (selectedIndex == _oldIndex) {
                var currentContext = _controllers[selectedIndex].tabView.navigatorKey?.currentContext;
                if (currentContext != null) {
                  Navigator.of(currentContext).popUntil((Route<dynamic> route) => route.isFirst);
                }
              }
              _oldIndex = selectedIndex;
            },
            items: _controllers
                .asMap()
                .map((index, aChild) {
                  return MapEntry(index, aChild.bottomView);
                })
                .values
                .toList(),
          ),
          tabBuilder: (innerContext, index) {
            return _controllers[index].tabView;
          },
        ),
      ),
    );
  }
}
