import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qui_green/resources/app_config.dart';
import 'package:qui_green/singletons/network/network_shared.dart';

class NetworkManager
    with
        NetworkGeneral,
        NetworkManagerUser,
        NetworkManagerNotification,
        NetworkManagerPackages,
        NetworkManagerPudo,
        NetworkManagerUserPudo {

  static final NetworkManager _inst = NetworkManager._internal(
    AppConfig(
        host: "https://api-dev.quigreen.it",
        isProd: false,
        appInfo: PackageInfo(
            appName: "",
            version: "1",
            packageName: "",
            buildNumber: "",
            buildSignature: "")),
  );

  static NetworkManager get instance {
    return NetworkManager._inst;
  }

  NetworkManager._internal(AppConfig _config);

  factory NetworkManager({required AppConfig config}) {
    _inst.networkActivity = ValueNotifier(false);
    _inst.config = config;
    _inst.baseURL = config.host;
    _inst.headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Application-Language': 'it',
      'User-Agent':
          'OpenPudo/${config.appInfo.version}#${config.appInfo.buildNumber}',
    };
    _inst.sharedPreferences = config.sharedPreferencesInstance!;
    _inst.accessToken =
        config.sharedPreferencesInstance!.getString('accessToken')!;
    Connectivity().onConnectivityChanged.listen(
      (result) {
        _inst.networkStatus = result;
      },
    );
    return _inst;
  }
}
