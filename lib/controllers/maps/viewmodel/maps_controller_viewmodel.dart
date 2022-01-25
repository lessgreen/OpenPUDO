import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qui_green/controllers/pudo_detail/models/pudo_detail_controller_data_model.dart';
import 'package:qui_green/models/pudo_marker.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
class MapsControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  onPudoClick(BuildContext context, PudoProfile data, LatLng position) {
    Navigator.of(context).pushReplacementNamed(Routes.pudoDetail,
        arguments: PudoDetailControllerDataModel(position, data));
  }

  MapController? mapController;


  var lastTriggeredLatitude = 45.4642;
  var lastTriggeredLongitude = 9.1900;
  var lastTriggeredZoom = 8;
  var currentLatitude = 45.4642;
  var currentLongitude = 9.1900;
  var currentZoomLevel = 8;

  updateCurrentMapPosition(MapPosition mapPosition){
    currentLatitude = mapPosition.center!.latitude;
    currentLongitude = mapPosition.center!.longitude;
    currentZoomLevel = mapPosition.zoom!.toInt();
  }

  updateLastMapPosition(MapPosition mapPosition){
    lastTriggeredLatitude = currentLatitude;
    lastTriggeredLongitude = currentLongitude;
    lastTriggeredZoom = currentZoomLevel;
  }

  List<PudoMarker> _pudos = [];
  List<PudoMarker> get pudos=>_pudos;
  set pudos(List<PudoMarker> newVal){
    _pudos = newVal;
    notifyListeners();
  }

  loadPudos() {
    NetworkManager.instance.getPudos(lat: currentLatitude, lon: currentLongitude, zoom: currentZoomLevel).then((response) {
      if (response is List<PudoMarker>) {
        if (_pudos.isNotEmpty && response.isEmpty) {
          mapController?.move(LatLng(currentLatitude, currentLongitude), currentZoomLevel.toDouble());
          return;
        }
          pudos = response;
        mapController?.move(LatLng(currentLatitude, currentLongitude), currentZoomLevel.toDouble());
      }
    });
  }

  PudoProfile? _pudoProfile;

  PudoProfile? get pudoProfile => _pudoProfile;

  set pudoProfile(PudoProfile? newVal){
    _pudoProfile = newVal;
    notifyListeners();
  }

  selectPudo(BuildContext context,int pudoId){

    NetworkManager.instance.getPudoDetails(pudoId: pudoId.toString()).then(
          (response) {
        if (response is PudoProfile) {
          pudoProfile = response;
        }
      },
    );
  }
}
