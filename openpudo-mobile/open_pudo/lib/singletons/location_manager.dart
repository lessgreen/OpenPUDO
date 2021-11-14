//
//  LocationManager.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 01/07/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:location/location.dart';

class LocationManager {
  Location _location = new Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  static final LocationManager _shared = LocationManager._internal();

  factory LocationManager() {
    return _shared;
  }

  LocationManager._internal() {
    //init method
  }

  Future<LocationData?> getCurrentLocation() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    return await _location.getLocation();
  }
}
