import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
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


  CurrentUser(this.sharedPreferences,{required this.pushPage}) {

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
      NetworkManager.instance
          .renewToken(accessToken: oldToken!)
          .then((response) {
        NetworkManager.instance.getMyProfile().then((profile) {
          user = profile;
          pushPage(Routes.home);
        }).catchError((onError) {
          user = null;
          pushPage(Routes.login);
          print(onError);
        });
      }).catchError((onError) {
        user = null;
        pushPage(Routes.login);
        print(onError);
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
    if (_user != null) {
      if (_user!.pudoOwner == true) {
        NetworkManager.instance.getMyPudoProfile().then(
          (pudoProfile) {
            if (pudoProfile is PudoProfile) {
              _pudo = pudoProfile;
              notifyListeners();
            }
          },
        ).catchError(
          (onError) {
            print(onError.toString());
          },
        );
      }
    } else {
      _pudo = null;
    }
    notifyListeners();
  }

  UserProfile? get user {
    return _user;
  }

  PudoProfile? get pudoProfile {
    return _pudo;
  }
}
