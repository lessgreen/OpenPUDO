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
import 'package:qui_green/singletons/dynamicLink_manager.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class PersonalDataControllerViewModel extends ChangeNotifier {
  Function(String)? showErrorDialog;

  String _name = DynamicLinkManager().dynamicLink?.data.firstName ?? "";

  String get name => _name;

  set name(String newVal) {
    _name = newVal;
    notifyListeners();
  }

  String _surname = DynamicLinkManager().dynamicLink?.data.lastName ?? "";

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
    NetworkManager.instance.registerUser(name: name, surname: surname, dynamicLinkId: DynamicLinkManager().magicLinkId).then((value) {
      var pudoId = DynamicLinkManager().dynamicLink?.data.favouritePudoId ?? pudoModel?.pudoId;
      DynamicLinkManager().dynamicLink = null;
      DynamicLinkManager().magicLinkId = null;
      if (value is ErrorDescription) {
        SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), value);
      } else {
        NetworkManager.instance.getMyProfile().then((user) {
          if (user is UserProfile) {
            Provider.of<CurrentUser>(context, listen: false).user = user;
            if (image != null) {
              NetworkManager.instance.photoUpload(image!).catchError((onError) => showErrorDialog?.call(onError));
            }
            if (pudoId != null) {
              NetworkManager.instance.addPudoFavorite(pudoId.toString()).then((value) {
                NetworkManager.instance.getPudoDetails(pudoId: pudoId.toString()).then((value) {
                  Navigator.of(context).pushReplacementNamed(Routes.registrationComplete, arguments: value as PudoProfile?);
                }).catchError((onError) => showErrorDialog?.call(onError));
              }).catchError((onError) => showErrorDialog?.call(onError));
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

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    locationData = await location.getLocation();
    return locationData;
  }

  pickFile(BuildContext context) async {
    showImageChoice(context, (value) {
      if (value != null) {
        image = value;
      }
    });
  }
}
