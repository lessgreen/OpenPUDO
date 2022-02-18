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
import 'package:location/location.dart';
import 'package:qui_green/models/geo_marker.dart';
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
  MapPosition? currentMapPosition;
  PageController pageController = PageController(viewportFraction: 0.95, initialPage: 0);
  MapController? mapController;
  Function(String)? showErrorDialog;
  late Function(MapsControllerViewModel, LatLng) animateMapTo;

  List<GeoMarker> _addresses = [];

  List<GeoMarker> get addresses => _addresses;

  set addresses(List<GeoMarker> newVal) {
    _addresses = newVal;
    notifyListeners();
  }

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

  onPudoClick(BuildContext context, GeoMarker marker, bool isOnboarding) {
    NetworkManager.instance.getPudoDetails(pudoId: marker.pudo!.pudoId.toString()).then(
      (response) {
        if (response is PudoProfile) {
          if (isOnboarding) {
            Navigator.of(context).pushNamed(Routes.pudoDetailOnBoarding, arguments: response);
          } else {
            Navigator.of(context).pushNamed(Routes.pudoDetail, arguments: response);
          }
        } else {
          showErrorDialog?.call("Qualcosa e' andato storto");
        }
      },
    ).catchError((onError) => showErrorDialog?.call(onError));
  }

  onMapCreate(MapController mapController, LatLng? center, bool getPosition) {
    this.mapController = mapController;
    NetworkManager.instance.getSuggestedZoom(lat: center?.latitude ?? currentLatitude, lon: center?.longitude ?? currentLongitude).then((value) {
      if (value is int) {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          mapController.move(center ?? LatLng(currentLatitude, currentLongitude), value.toDouble());
        });
        if (getPosition) {
          tryGetUserLocation();
        }
      }
    });
  }

  Future<LocationData?> tryGetUserLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

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
    return location.getLocation().then((value) {
      position = LatLng(value.latitude ?? 45.464664, value.longitude ?? 9.188540);
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        animateMapTo(this, position);
      });
      return Future.value(value);
    }).timeout(const Duration(seconds: 2), onTimeout: () {
      return Future.error("Errore nella localizzazione.\nSi prega di riprovare");
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
    currentMapPosition = mapPosition;
  }

  updateLastMapPosition(MapPosition mapPosition) {
    lastTriggeredLatitude = currentLatitude;
    lastTriggeredLongitude = currentLongitude;
    lastTriggeredZoom = currentZoomLevel;
  }

  loadPudos({bool requireZoomLevelRefresh = false}) {
    NetworkManager.instance.getSuggestedZoom(lat: currentLatitude, lon: currentLongitude).then((value) {
      if (value is int && requireZoomLevelRefresh) {
        currentZoomLevel = value;
        lastTriggeredZoom = currentZoomLevel;
      }
      NetworkManager.instance.getPudos(lat: currentLatitude, lon: currentLongitude, zoom: currentZoomLevel).then((response) {
        if (response is List<GeoMarker>) {
          if (pudos.isEmpty) {
            if (response.isNotEmpty) {
              showingCardPudo = response[0].pudo!.pudoId;
            }
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
    if (newPudos.isNotEmpty) {
      List<GeoMarker> oldPudos = List<GeoMarker>.from(pudos);
      if (oldPudos.length >= _maxLoadedPudos) {
        //removes oldest fetched pudos if oldPudos exceeds the maxLoaded
        oldPudos.removeRange(0, newPudos.length > oldPudos.length ? oldPudos.length - 1 : newPudos.length - 1);
      }
      for (GeoMarker i in newPudos) {
        //if never fetched add the newFetchedPudo
        if (!oldPudos.any((element) => element.pudo?.pudoId == i.pudo?.pudoId)) {
          oldPudos.add(i);
        }
      }
      return oldPudos;
    }
    return pudos;
  }

  selectPudo(BuildContext context, GeoMarker? marker, bool enabledCards, bool isOnboarding) {
    if (marker == null) {
      return;
    }
    if (enabledCards) {
      isReloadingPudos = true;
      for (var i = 0; i < pudos.length; i++) {
        if (pudos[i].pudo?.pudoId == marker.pudo!.pudoId) {
          pageController.animateToPage(i, duration: const Duration(milliseconds: 150), curve: Curves.easeIn).then((value) {
            isReloadingPudos = false;
            showingCardPudo = marker.pudo!.pudoId;
          });
          return;
        }
      }
    } else {
      onPudoClick(context, marker, isOnboarding);
    }
  }

  int _showingCardPudo = 0;

  int get showingCardPudo => _showingCardPudo;

  set showingCardPudo(int newVal) {
    _showingCardPudo = newVal;
    notifyListeners();
  }

  bool _isOpenListAddress = false;

  bool get isOpenListAddress => _isOpenListAddress;

  set isOpenListAddress(bool newVal) {
    _isOpenListAddress = newVal;
    notifyListeners();
  }

  LatLng position = LatLng(45.464664, 9.188540);

  TextEditingController addressController = TextEditingController();

  void onSearchChanged(String query) {
    if (_debounce.isActive) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      fetchSuggestions(query);
    });
  }

  Future<void> fetchSuggestions(String val) async {
    if (val.trim().isNotEmpty) {
      var res = await NetworkManager.instance.getGeoMarkers(text: val);
      if (res is List<GeoMarker>) {
        if (res.isNotEmpty) {
          addresses = res;
          isOpenListAddress = true;
        } else {
          addresses = [];
          isOpenListAddress = false;
        }
        return;
      }
    } else {
      addresses = [];
      isOpenListAddress = false;
    }
  }
}
