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
    Navigator.of(context).pushReplacementNamed(Routes.maps,arguments: pos);
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
    pos = LatLng(_locationData.latitude??45.464664,_locationData.longitude??9.188540);
    return _locationData;
  }
}
