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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qui_green/resources/app_config.dart';
import 'package:qui_green/singletons/network/network_shared.dart';

class NetworkManager with NetworkGeneral, NetworkManagerUser, NetworkManagerNotification, NetworkManagerPackages, NetworkManagerPudo, NetworkManagerUserPudo {
  static final NetworkManager _inst = NetworkManager._internal(
    AppConfig(
      host: "https://api-dev.quigreen.it",
      isProd: false,
      appInfo: PackageInfo(appName: "", version: "1", packageName: "", buildNumber: "", buildSignature: ""),
    ),
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
      'User-Agent': 'OpenPudo/${config.appInfo.version}#${config.appInfo.buildNumber}',
    };
    _inst.sharedPreferences = config.sharedPreferencesInstance!;
    _inst.accessToken = config.sharedPreferencesInstance!.getString('accessToken') ?? "";
    Connectivity().checkConnectivity().then((value) => _inst.networkStatus=value);
    Connectivity().onConnectivityChanged.listen(
      (result) {
        _inst.networkStatus = result;
      },
    );
    return _inst;
  }
}
