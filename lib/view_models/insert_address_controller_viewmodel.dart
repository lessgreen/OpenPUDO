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

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:qui_green/models/address_model.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class InsertAddressControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation *****
  onSendClick(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.maps, arguments: position);
  }

  TextEditingController addressController = TextEditingController();

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

  Timer debounce = Timer(const Duration(days: 1), () {});

  LatLng position = LatLng(45.464664, 9.188540);

  void onSearchChanged(String query, Function() onAfter) {
    if (debounce.isActive) debounce.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      fetchSuggestions(query, onAfter);
    });
  }

  bool _mountedOverlay = false;

  bool get mountedOverlay => _mountedOverlay;

  set mountedOverlay(bool newVal) {
    _mountedOverlay = newVal;
    notifyListeners();
  }

  bool _isSelectingFromOverlay = false;

  bool get isSelectingFromOverlay => _isSelectingFromOverlay;

  set isSelectingFromOverlay(bool newVal) {
    _isSelectingFromOverlay = newVal;
    notifyListeners();
  }

  List<AddressModel> _addresses = [];

  List<AddressModel> get addresses => _addresses;

  set addresses(List<AddressModel> newVal) {
    _addresses = newVal;
    notifyListeners();
  }

  Future<void> fetchSuggestions(String val, Function() onAfter) async {
    if (val.trim().isNotEmpty) {
      var res = await NetworkManager.instance.getAddresses(text: val);
      if (res is List<AddressModel>) {
        if (res.isNotEmpty) {
          addresses = res;
          onAfter();
        } else {
          addresses = [];
        }
        return;
      }
    } else {
      addresses = [];
    }
  }

  bool _hasSelected = false;

  bool get hasSelected => _hasSelected;

  set hasSelected(bool newVal) {
    _hasSelected = newVal;
    notifyListeners();
  }
}
