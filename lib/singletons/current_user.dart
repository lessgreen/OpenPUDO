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

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:qui_green/commons/utilities/print_helper.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUser with ChangeNotifier {
  bool fetchOnOpenApp = false;
  bool firstNavigationDone = false;
  UserProfile? _user;
  PudoProfile? _pudo;
  SharedPreferences? sharedPreferences;
  Function(String) pushPage;

  CurrentUser(this.sharedPreferences, {required this.pushPage}) {
    Connectivity().onConnectivityChanged.listen((result) {
      switch (result) {
        case ConnectivityResult.none:
          break;
        default:
          _refreshToken();
      }
    });
    _refreshToken();
  }

  void refresh() {
    firstNavigationDone = false;
    _refreshToken();
  }

  _refreshToken() {
    if (sharedPreferences?.getString('accessToken') != null) {
      var oldToken = sharedPreferences?.getString('accessToken');
      NetworkManager.instance.renewToken(accessToken: oldToken!).then((response) {
        switch (NetworkManager.instance.accessTokenAccess) {
          case "customer":
            NetworkManager.instance.getMyProfile().then((profile) {
              user = profile;
              pushPage(Routes.home);
            }).catchError((onError) {
              user = null;
              pushPage(Routes.login);
              safePrint(onError);
            });
            break;
          case "pudo":
            NetworkManager.instance.getMyPudoProfile().then((profile) {
              pudoProfile = profile;
              pushPage(Routes.pudoHome);
            }).catchError((onError) {
              user = null;
              pushPage(Routes.login);
              safePrint(onError);
            });
            break;
          case "guest":
            pushPage(Routes.aboutYou);
            break;
          default:
            safePrint("wrong access type");
            break;
        }
      }).catchError((onError) {
        user = null;
        pushPage(Routes.login);
        safePrint(onError);
      });
    } else {
      user = null;
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        pushPage(Routes.login);
      });
    }
  }

  set pudoProfile(PudoProfile? newProfile) {
    _pudo = newProfile;
    notifyListeners();
  }

  set user(UserProfile? newProfile) {
    _user = newProfile;
    notifyListeners();
  }

  UserProfile? get user {
    return _user;
  }

  PudoProfile? get pudoProfile {
    return _pudo;
  }
}
