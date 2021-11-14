import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:open_pudo/models/pudo_profile.dart';
import 'package:open_pudo/models/user_profile.dart';
import 'package:open_pudo/singletons/device_manager.dart';
import '../main.dart';
import 'network.dart';

class CurrentUser with ChangeNotifier {
  UserProfile? _user;
  PudoProfile? _pudo;

  CurrentUser() {
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

  _refreshToken() {
    if (sharedPreferences?.getString('accessToken') != null) {
      var oldToken = sharedPreferences?.getString('accessToken');
      NetworkManager().renewToken(accessToken: oldToken!).then((response) {
        NetworkManager().getMyProfile().then((profile) {
          this.user = profile;
        }).catchError((onError) {
          this.user = null;
          print(onError);
        });
      }).catchError((onError) {
        this.user = null;
        print(onError);
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
        NetworkManager().getMyPudoProfile().then(
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
      FirebaseMessaging.instance.requestPermission().then((value) {
        print(value);
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
                NetworkManager()
                    .setDeviceInfo(infoRequest: deviceInfo)
                    .then(
                      (value) => print(value),
                    )
                    .catchError(
                      (onError) => print(onError.toString()),
                    );
              }
            });
            print('DEBUGTOKEN: $token');
          },
        );
      });
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
