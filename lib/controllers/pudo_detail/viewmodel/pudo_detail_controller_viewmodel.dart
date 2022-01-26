import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';

class PudoDetailControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation *****
  goBack(BuildContext context, LatLng initialPos) {
    Navigator.of(context)
        .pushReplacementNamed(Routes.maps, arguments: initialPos);
  }

  onSelectPress(BuildContext context, PudoProfile pudoModel) async {
    Navigator.of(context)
        .pushReplacementNamed(Routes.personalData, arguments: pudoModel);
  }
}
