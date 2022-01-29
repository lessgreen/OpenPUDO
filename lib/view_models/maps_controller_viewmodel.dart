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
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qui_green/models/pudo_detail_controller_data_model.dart';
import 'package:qui_green/models/pudo_marker.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class MapsControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  onPudoClick(BuildContext context, PudoMarker data, LatLng position) {
    NetworkManager.instance
        .getPudoDetails(pudoId: data.pudo.pudoId.toString())
        .then(
      (response) {
        if (response is PudoProfile) {
          Navigator.of(context).pushNamed(Routes.pudoDetail,
              arguments: PudoDetailControllerDataModel(position, response));
        } else {
          showErrorDialog!("Qualcosa e' andato storto");
        }
      },
    ).catchError((onError) => showErrorDialog!(onError));
  }

  MapController? mapController;

  onMapCreate(MapController mapController,LatLng center) {
    this.mapController = mapController;
    NetworkManager.instance
        .getSuggestedZoom(
            lat: center.latitude,
            lon: center.longitude)
        .then((value) {
      if (value is int) {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          mapController.move(center, value.toDouble());
        });
      }
    });
  }

  Function(String)? showErrorDialog;

  var lastTriggeredLatitude = 45.4642;
  var lastTriggeredLongitude = 9.1900;
  var lastTriggeredZoom = 8;
  var currentLatitude = 45.4642;
  var currentLongitude = 9.1900;
  var currentZoomLevel = 8;

  updateCurrentMapPosition(MapPosition mapPosition) {
    currentLatitude = mapPosition.center!.latitude;
    currentLongitude = mapPosition.center!.longitude;
    currentZoomLevel = mapPosition.zoom!.toInt();
  }

  updateLastMapPosition(MapPosition mapPosition) {
    lastTriggeredLatitude = currentLatitude;
    lastTriggeredLongitude = currentLongitude;
    lastTriggeredZoom = currentZoomLevel;
  }

  List<PudoMarker> _pudos = [];

  List<PudoMarker> get pudos => _pudos;

  set pudos(List<PudoMarker> newVal) {
    _pudos = newVal;
    notifyListeners();
  }

  loadPudos() {
    NetworkManager.instance
        .getPudos(
            lat: currentLatitude, lon: currentLongitude, zoom: currentZoomLevel)
        .then((response) {
      if (response is List<PudoMarker>) {
        if (_pudos.isNotEmpty && response.isEmpty) {
          mapController?.move(LatLng(currentLatitude, currentLongitude),
              currentZoomLevel.toDouble());
          return;
        }
        pudos = response;
        mapController?.move(LatLng(currentLatitude, currentLongitude),
            currentZoomLevel.toDouble());
      }
    }).catchError((onError) => showErrorDialog!(onError));
  }

  PudoMarker? _selectedPudoMarker;

  PudoMarker? get selectedPudoMarker => _selectedPudoMarker;

  set selectedPudoMarker(PudoMarker? newVal) {
    _selectedPudoMarker = newVal;
    notifyListeners();
  }
}
