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

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:qui_green/commons/ui/tab_controller_container.dart';
import 'package:qui_green/commons/utilities/fcm_helper.dart';
import 'package:qui_green/commons/utilities/home_user_routes.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/controllers/home_user_packages.dart';
import 'package:qui_green/controllers/onboarding/map_controller.dart';
import 'package:qui_green/controllers/profile_controller.dart';
import 'package:qui_green/controllers/pudo_list_controller.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class HomeController extends StatefulWidget {
  const HomeController({Key? key}) : super(key: key);

  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> with ConnectionAware {
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
          builder: (subContext) {
            return const HomeUserPackages();
          },
          onGenerateRoute: (RouteSettings settings) => homeUserRouteWithSetting(settings),
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
          builder: (context) => const MapController.homeUser(),
          onGenerateRoute: (RouteSettings settings) => homeUserRouteWithSetting(settings),
        ),
        bottomView: BottomNavigationBarItem(
          icon: SvgPicture.asset(ImageSrc.mapsArt, color: Colors.grey.shade400),
          activeIcon: SvgPicture.asset(ImageSrc.mapsArt, color: AppColors.primaryColorDark),
          label: 'Map',
        ),
      ),
      TabControllerContainer(
        tabView: CupertinoTabView(
          navigatorKey: GlobalKey(),
          builder: (context) => const PudoListController(
            isRootController: true,
          ),
          onGenerateRoute: (RouteSettings settings) => homeUserRouteWithSetting(settings),
        ),
        bottomView: BottomNavigationBarItem(
          icon: SvgPicture.asset(ImageSrc.packReceivedLeadingIcon, color: Colors.grey.shade400),
          activeIcon: SvgPicture.asset(ImageSrc.packReceivedLeadingIcon, color: AppColors.primaryColorDark),
          label: 'Pudos',
        ),
      ),
      TabControllerContainer(
        tabView: CupertinoTabView(
          navigatorKey: GlobalKey(),
          builder: (context) => const ProfileController(),
          onGenerateRoute: (RouteSettings settings) => homeUserRouteWithSetting(settings),
        ),
        bottomView: BottomNavigationBarItem(
          icon: SvgPicture.asset(ImageSrc.profileArt, color: Colors.grey.shade400),
          activeIcon: SvgPicture.asset(ImageSrc.profileArt, color: AppColors.primaryColorDark),
          label: 'Profile',
        ),
      )
    ];
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _handleInitialMessage(_controllers.first.tabView.navigatorKey!.currentContext!);
      _handleMessages(_controllers.first.tabView.navigatorKey!.currentContext!);
    });
  }

  void _handleMessages(BuildContext subContext) {
    ///Handles what to do when a notification is opened when app is in background
    FirebaseMessaging.onMessage.listen((RemoteMessage message) => firebaseMessagingOpenedAppHandler(subContext, message));

    ///Handles showing the material banner when a notification is received
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) => firebaseMessagingHandler(subContext, message));
  }

  ///Checks if an initialMessage is available from the app in a closed state (open app from notification)
  void _handleInitialMessage(BuildContext subContext) async {
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      if (message.data.containsKey("packageId")) {
        handlePackageRouting(subContext, int.parse(message.data["packageId"]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controllers.isEmpty
        ? const SizedBox()
        : Material(
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
