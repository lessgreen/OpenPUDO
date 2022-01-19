import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:qui_green/models/address_marker.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network.dart';

class InsertAddressControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation *****
  onSendClick(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.maps);
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

  Future<List<AddressMarker>> fetchSuggestions(String val) async {
    var res = NetworkManager.instance.getAddresses(text: val);
    if (res is List<AddressMarker>) {
      (res as List<AddressMarker>).map((e) => print(e.label));
      return res as List<AddressMarker>;
    }
    return [];
  }
}
