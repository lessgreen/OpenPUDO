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
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/models/pudo_detail_controller_data_model.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class MapsControllerViewModel extends ChangeNotifier {
  var lastTriggeredLatitude = 45.4642;
  var lastTriggeredLongitude = 9.1900;
  var lastTriggeredZoom = 8;
  var currentLatitude = 45.4642;
  var currentLongitude = 9.1900;
  var currentZoomLevel = 8;
  PageController pageController =
      PageController(viewportFraction: 0.95, initialPage: 0);
  MapController? mapController;
  Function(String)? showErrorDialog;

  bool _isReloadingPudos = false;

  bool get isReloadingPudos => _isReloadingPudos;

  set isReloadingPudos(bool newVal) {
    _isReloadingPudos = newVal;
    notifyListeners();
  }

  List<GeoMarker> _pudos = [];

  List<GeoMarker> get pudos => _pudos;

  set pudos(List<GeoMarker> newVal) {
    _pudos = newVal;
    notifyListeners();
  }

  GeoMarker? _pudoProfile;

  GeoMarker? get pudoProfile => _pudoProfile;

  set pudoProfile(GeoMarker? newVal) {
    _pudoProfile = newVal;
    notifyListeners();
  }

  onPudoClick(BuildContext context, GeoMarker marker, LatLng position) {
    NetworkManager.instance
        .getPudoDetails(pudoId: marker.pudo!.pudoId.toString())
        .then(
      (response) {
        if (response is PudoProfile) {
          Navigator.of(context).pushNamed(Routes.pudoDetail,
              arguments: PudoDetailControllerDataModel(position, response));
        } else {
          showErrorDialog?.call("Qualcosa e' andato storto");
        }
      },
    ).catchError((onError) => showErrorDialog?.call(onError));
  }

  onMapCreate(MapController mapController, LatLng center) {
    this.mapController = mapController;
    NetworkManager.instance
        .getSuggestedZoom(lat: center.latitude, lon: center.longitude)
        .then((value) {
      if (value is int) {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          mapController.move(center, value.toDouble());
        });
      }
    });
  }

  Timer _debounce = Timer(const Duration(days: 1), () {});

  onMapChange({bool requireZoomLevelRefresh = false}) {
    if (_debounce.isActive) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      loadPudos(requireZoomLevelRefresh: requireZoomLevelRefresh);
    });
  }

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

  loadPudos({bool requireZoomLevelRefresh = false}) {
    NetworkManager.instance
        .getSuggestedZoom(lat: currentLatitude, lon: currentLongitude)
        .then((value) {
      if (value is int && requireZoomLevelRefresh) {
        currentZoomLevel = value;
        lastTriggeredZoom = currentZoomLevel;
      }
      NetworkManager.instance
          .getPudos(
              lat: currentLatitude,
              lon: currentLongitude,
              zoom: currentZoomLevel)
          .then((response) {
        if (response is List<GeoMarker>) {
          if (pudos.isEmpty) {
            showingCardPudo = response[0].pudo!.pudoId;
          }
          pudos = smartPlacement(response);
        }
      }).catchError((onError) => showErrorDialog?.call(onError));
    }).catchError((onError) => showErrorDialog?.call(onError));
  }

  ///
  /// Experimental method it's going to be tweaked more in the future with more accuracy
  /// Newest fetched pudos are always added at the end (only if the pudo doest already exists the list)
  ///
  /// _maxLoadedPudos To be set to 100 when enough pudos created
  ///
  final int _maxLoadedPudos = 20;

  List<GeoMarker> smartPlacement(List<GeoMarker> newPudos) {
    List<GeoMarker> oldPudos = List<GeoMarker>.from(pudos);

    if (oldPudos.length >= _maxLoadedPudos) {
      //removes oldest fetched pudos if oldPudos exceeds the maxLoaded
      oldPudos.removeRange(
          0,
          newPudos.length > oldPudos.length
              ? oldPudos.length - 1
              : newPudos.length - 1);
    }
    for (GeoMarker i in newPudos) {
      //if never fetched add the newFetchedPudo
      if (!oldPudos.any((element) => element.pudo?.pudoId == i.pudo?.pudoId)) {
        oldPudos.add(i);
      }
    }
    return oldPudos;
  }

  selectPudo(BuildContext context, int? pudoId) {
    if (pudoId == null) {
      return;
    }
    isReloadingPudos = true;
    for (var i = 0; i < pudos.length; i++) {
      if (pudos[i].pudo?.pudoId == pudoId) {
        pageController.animateToPage(i,
            duration: const Duration(milliseconds: 150), curve: Curves.easeIn).then((value){
          isReloadingPudos = false;
          showingCardPudo = pudoId;
        });
        return;
      }
    }
  }

  int _showingCardPudo = 0;

  int get showingCardPudo => _showingCardPudo;

  set showingCardPudo(int newVal) {
    _showingCardPudo = newVal;
    notifyListeners();
  }
}
