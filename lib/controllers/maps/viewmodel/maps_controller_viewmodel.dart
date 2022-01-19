import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qui_green/resources/routes_enum.dart';

class MapsControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation ***********
  onPudoClick(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.pudoDetail);
  }

  final MapController mapController = MapController();

  final List<LatLng> list = [
    LatLng(41.890210, 12.492231),
    LatLng(45.464664, 9.188540),
  ];

  onPudoListChange(int newVal) {
    mapController.moveAndRotate(list[newVal], 13,0);
  }
}
