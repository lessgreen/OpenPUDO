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

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qui_green/commons/utilities/print_helper.dart';
import 'package:qui_green/models/device_info_model.dart';

class DeviceManager {
  static final DeviceManager _shared = DeviceManager._internal();
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  BuildContext? _context;

  factory DeviceManager() {
    return _shared;
  }

  DeviceManager._internal() {
    //init method
  }

  setContext(BuildContext context) {
    _context = context;
  }

  Future<DeviceInfoModel?> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        return _readAndroidBuildData(await _deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        return _readIosDeviceInfo(await _deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      safePrint("unable to get deviceInfoModel");
      return null;
    }
    return null;
  }

  DeviceInfoModel _readAndroidBuildData(AndroidDeviceInfo data) {
    var retValue = DeviceInfoModel(
      deviceType: "Android",
      systemName: data.version.codename,
      systemVersion: data.version.release,
      model: data.model,
      resolution: "n/a",
    );
    if (_context != null) {
      retValue.resolution = "${MediaQuery.of(_context!).size.width}x${MediaQuery.of(_context!).size.height}";
    }
    return retValue;
  }

  DeviceInfoModel _readIosDeviceInfo(IosDeviceInfo data) {
    var retValue = DeviceInfoModel(
      deviceType: "iOS",
      systemName: data.systemName,
      systemVersion: data.systemVersion,
      model: data.model,
      resolution: "n/a",
    );
    if (_context != null) {
      retValue.resolution = "${MediaQuery.of(_context!).size.width}x${MediaQuery.of(_context!).size.height}";
    }
    return retValue;
  }
}
