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

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/resources/app_config.dart';
import 'package:qui_green/singletons/network/network_commons.dart';

class NetworkManager with NetworkGeneral, NetworkManagerUser, NetworkManagerNotification, NetworkManagerPackages, NetworkManagerPudo, NetworkManagerUserPudo, NetworkShare {
  BuildContext? context;
  final _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> networkSubscription;

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

  // ignore: no_leading_underscores_for_local_identifiers
  NetworkManager._internal(AppConfig _config);

  String get currentLanguage {
    final WidgetsBinding instance = WidgetsBinding.instance;
    final List<Locale> systemLocales = instance.window.locales;
    String languageCode = systemLocales.first.languageCode;
    return languageCode;
  }

  NetworkManager({required AppConfig config}) {
    _checkNetwork();
    _inst.networkSubscription = _connectivity.onConnectivityChanged.listen((result) {
      Future.delayed(const Duration(seconds: 1), () {
        _checkStatus();
      });
    });
    _inst.networkActivity = ValueNotifier(false);
    _inst.config = config;
    _inst.baseURL = config.host;
    _inst.headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Application-Language': currentLanguage,
      'User-Agent': 'OpenPudo/${config.appInfo.version}#${config.appInfo.buildNumber}',
    };
    _inst.sharedPreferences = config.sharedPreferencesInstance!;
    _inst.accessToken = config.sharedPreferencesInstance!.getString('accessToken') ?? "";
  }

  void _checkNetwork() async {
    await _inst._connectivity.checkConnectivity();
    _checkStatus();
  }

  void _checkStatus() async {
    try {
      final lookupResult = await InternetAddress.lookup('www.google.com');
      _inst.isOnline = lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _inst.isOnline = false;
    }
    if (!_inst.isOnline) {
      _showNetworkError();
    }
    log(_inst.isOnline ? "Online" : "Offline");
  }

  void _showNetworkError() {
    if (_inst.context != null) {
      SAAlertDialog.displayAlertWithClose(
        _inst.context!,
        'localized'.localized(_inst.context!),
        'workingInternetConnection'.localized(_inst.context!),
      );
    }
  }
}

mixin ConnectionAware<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    NetworkManager.instance.context = context;
  }
}
