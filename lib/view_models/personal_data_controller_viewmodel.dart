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

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/image_picker_helper.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class PersonalDataControllerViewModel extends ChangeNotifier {
  Function(String)? showErrorDialog;

  String _name = "";

  String get name => _name;

  set name(String newVal) {
    _name = newVal;
    notifyListeners();
  }

  String _surname = "";

  String get surname => _surname;

  set surname(String newVal) {
    _surname = newVal;
    notifyListeners();
  }

  File? _image;

  File? get image => _image;

  set image(File? newVal) {
    _image = newVal;
    notifyListeners();
  }

  get isValid {
    if (_name.isNotEmpty && _surname.isNotEmpty) {
      return true;
    }
    return false;
  }

  // ************ Navigation *****
  onSendClick(BuildContext context, PudoProfile? pudoModel) {
    NetworkManager.instance.registerUser(name: name, surname: surname).then((value) {
      if (value is ErrorDescription) {
        SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), value);
      } else {
        NetworkManager.instance.getMyProfile().then((user) {
          if (user is UserProfile) {
            Provider.of<CurrentUser>(context, listen: false).user = user;
            if (image != null) {
              NetworkManager.instance.photoUpload(image!).catchError((onError) => showErrorDialog?.call(onError));
            }
            if (pudoModel != null) {
              NetworkManager.instance.addPudoFavorite(pudoModel.pudoId.toString()).catchError((onError) => showErrorDialog?.call(onError));
            }
            if (pudoModel != null) {
              Navigator.of(context).pushReplacementNamed(Routes.registrationComplete, arguments: pudoModel);
            } else {
              Navigator.of(context).pushReplacementNamed(Routes.userPudoTutorial, arguments: PudoProfile.fakeProfile);
            }
          } else {
            showErrorDialog?.call('unknownDescription'.localized(context, 'general'));
          }
        }).catchError((onError) => showErrorDialog?.call(onError));
      }
    }).catchError((onError) => showErrorDialog?.call(onError));
  }

  // ************ Location *******

  Future<LocationData?> tryGetUserLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  pickFile(BuildContext context) async {
    showImageChoice(context, (value) {
      if (value != null) {
        image = value;
      }
    });
  }
}
