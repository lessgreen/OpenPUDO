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
import 'package:latlong2/latlong.dart';
import 'package:qui_green/models/address_model.dart';
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class InsertAddressControllerViewModel extends ChangeNotifier {
  Timer _debounce = Timer(const Duration(days: 1), () {});
  LatLng position = LatLng(45.464664, 9.188540);
  TextEditingController addressController = TextEditingController();

  bool _mountedOverlay = false;
  bool get mountedOverlay => _mountedOverlay;
  set mountedOverlay(bool newVal) {
    _mountedOverlay = newVal;
    notifyListeners();
  }

  bool _isSelectingFromOverlay = false;
  bool get isSelectingFromOverlay => _isSelectingFromOverlay;
  set isSelectingFromOverlay(bool newVal) {
    _isSelectingFromOverlay = newVal;
    notifyListeners();
  }

  List<GeoMarker> _addresses = [];
  List<GeoMarker> get addresses => _addresses;
  set addresses(List<GeoMarker> newVal) {
    _addresses = newVal;
    notifyListeners();
  }

  bool _hasSelected = false;
  bool get hasSelected => _hasSelected;
  set hasSelected(bool newVal) {
    _hasSelected = newVal;
    notifyListeners();
  }

  onSendClick(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.maps, arguments: position);
  }

  void onSearchChanged(String query, Function() onAfter) {
    if (_debounce.isActive) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      fetchSuggestions(query, onAfter);
    });
  }

  Future<void> fetchSuggestions(String val, Function() onAfter) async {
    if (val.trim().isNotEmpty) {
      var res = await NetworkManager.instance.getAddresses(text: val);
      if (res is List<GeoMarker>) {
        if (res.isNotEmpty && res.addresses != null) {
          addresses = res;
          onAfter();
        } else {
          addresses = [];
        }
        return;
      }
    } else {
      addresses = [];
    }
  }
}
