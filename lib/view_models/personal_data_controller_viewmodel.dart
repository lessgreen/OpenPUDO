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

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/utilities/print_helper.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class PersonalDataControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  Function(String)? showErrorDialog;

  // ************ Navigation *****
  onSendClick(BuildContext context, PudoProfile? pudoModel) {
    NetworkManager.instance
        .registerUser(name: name, surname: surname)
        .then((value) {
      NetworkManager.instance.getMyProfile().then((user) {
        Provider.of<CurrentUser>(context, listen: false).user = user;
        if (image != null) {
          NetworkManager.instance
              .photoUpload(image!)
              .catchError((onError) => showErrorDialog!(onError));
        }
        if (pudoModel != null) {
          NetworkManager.instance
              .addPudoFavorite(pudoModel.pudoId.toString())
              .catchError((onError) => showErrorDialog!(onError));
        }
        Navigator.of(context).pushReplacementNamed(Routes.registrationComplete,
            arguments: pudoModel);
      }).catchError((onError) => showErrorDialog!(onError));
    }).catchError((onError) => showErrorDialog!(onError));
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

  String _name = "";
  String _surname = "";

  String get name => _name;

  String get surname => _surname;

  set name(String newVal) {
    _name = newVal;
    notifyListeners();
  }

  set surname(String newVal) {
    _surname = newVal;
    notifyListeners();
  }

  get isValid {
    if (_image != null) {
      return true;
    }
    if (_name.isEmpty) {
      return false;
    }
    if (_surname.isEmpty) {
      return false;
    }
    return true;
  }

  File? _image;

  File? get image => _image;

  set image(File? newVal) {
    _image = newVal;
    notifyListeners();
  }

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (result != null) {
      try {
        File file = File(result.files.first.path ?? "");
        image = file;
      } catch (e) {
        safePrint(e.toString());
      }
    } else {
      // User canceled the picker
    }
  }
}
