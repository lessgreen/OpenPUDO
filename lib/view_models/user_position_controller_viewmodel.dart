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

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:qui_green/resources/routes_enum.dart';

class UserPositionControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation *****
  onAddAddressClick(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.insertAddress);
  }

  onMapClick(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.maps, arguments: pos);
  }

  LatLng pos = LatLng(45.464664, 9.188540);

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
    pos = LatLng(_locationData.latitude ?? 45.464664, _locationData.longitude ?? 9.188540);
    return _locationData;
  }
}
