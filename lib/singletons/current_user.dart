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
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:qui_green/commons/utilities/print_helper.dart';
import 'package:qui_green/models/base_response.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/device_manager.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUser with ChangeNotifier {
  UserProfile? _user;
  PudoProfile? _pudo;
  SharedPreferences? sharedPreferences;
  Function(String) pushPage;

  CurrentUser(this.sharedPreferences, {required this.pushPage}) {
    _refreshToken();
  }

  void refresh() {
    _refreshToken();
  }

  _refreshToken() {
    if (sharedPreferences?.getString('accessToken') != null) {
      var oldToken = sharedPreferences?.getString('accessToken');
      NetworkManager.instance.renewToken(accessToken: oldToken!).then((response) {
        if (response is OPBaseResponse) {
          switch (NetworkManager.instance.accessTokenAccess) {
            case "customer":
              NetworkManager.instance.getMyProfile().then((profile) {
                if (profile != null) {
                  user = profile;
                  pushPage(Routes.home);
                  refreshFcmToken();
                }
              }).catchError((onError) {
                user = null;
                pushPage(Routes.login);
                safePrint(onError);
              });
              break;
            case "pudo":
              NetworkManager.instance.getMyPudoProfile().then((profile) {
                if (profile != null) {
                  pudoProfile = profile;
                  pushPage(Routes.pudoHome);
                  refreshFcmToken();
                }
              }).catchError((onError) {
                pudoProfile = null;
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
        } else if (response is ErrorDescription) {
          user = null;
          pudoProfile = null;
          pushPage(Routes.login);
        }
      }).catchError((onError) {
        user = null;
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          pushPage(Routes.login);
        });
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

  void triggerReload() {
    notifyListeners();
  }

  void triggerUserReload() {
    switch (NetworkManager.instance.accessTokenAccess) {
      case "customer":
        NetworkManager.instance.getMyProfile().then((profile) {
          if (profile != null) {
            user = profile;
            notifyListeners();
          }
        }).catchError((onError) {
          user = null;
          pushPage(Routes.login);
          safePrint(onError);
        });
        break;
      case "pudo":
        NetworkManager.instance.getMyPudoProfile().then((profile) {
          if (profile != null) {
            pudoProfile = profile;
            notifyListeners();
          }
        }).catchError((onError) {
          pudoProfile = null;
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
  }

  void refreshFcmToken() {
    FirebaseMessaging.instance.requestPermission().then((NotificationSettings value) {
      FlutterAppBadger.isAppBadgeSupported().then((value) {
        if (value == true) {
          FlutterAppBadger.removeBadge();
        }
      });
      FirebaseMessaging.instance.getToken().then(
        (token) {
          DeviceManager().getDeviceInfo().then((deviceInfo) {
            if (deviceInfo != null) {
              deviceInfo.deviceToken = token ?? "SIMULATOR-FAKE-TOKEN-DO-NOT-USE";
              NetworkManager.instance
                  .setDeviceInfo(infoRequest: deviceInfo)
                  .then(
                    (value) => safePrint(value),
                  )
                  .catchError(
                    (onError) => safePrint(onError.toString()),
                  );
            }
          });
          safePrint('DEBUGTOKEN: $token');
        },
      );
    });
  }
}
