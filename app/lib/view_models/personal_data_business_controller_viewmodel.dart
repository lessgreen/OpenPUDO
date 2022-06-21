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
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:location/location.dart';
import 'package:qui_green/commons/utilities/image_picker_helper.dart';
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/registration_pudo_model.dart';
import 'package:qui_green/models/registration_pudo_request.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class PersonalDataBusinessControllerViewModel extends ChangeNotifier {
  PersonalDataBusinessControllerViewModel(String phoneNumber) {
    this.phoneNumber = phoneNumber;
    phoneNumberController.text = phoneNumber;
  }

  Function(String)? showErrorDialog;

  String _name = "";

  String get name => _name;

  set name(String newVal) {
    _name = newVal;
    notifyListeners();
  }

  TextEditingController phoneNumberController = TextEditingController(text: "");

  String _phoneNumber = "";

  String get phoneNumber => _phoneNumber;

  set phoneNumber(String newVal) {
    _phoneNumber = newVal;
    notifyListeners();
  }

  File? _image;

  File? get image => _image;

  set image(File? newVal) {
    _image = newVal;
    notifyListeners();
  }

  Future<bool> get isValid async {
    if (_name.isEmpty) {
      return false;
    }
    PhoneNumber? isValidPhoneNumber;
    try {
      isValidPhoneNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(_phoneNumber);
    } catch (e) {
      isValidPhoneNumber = null;
    }

    if (_phoneNumber.isEmpty || isValidPhoneNumber == null) {
      return false;
    }
    return true;
  }

  PudoAddressMarker? _address;

  PudoAddressMarker? get address => _address;

  PudoAddressMarker convertGeoMarker(GeoMarker marker) {
    return PudoAddressMarker(signature: marker.signature!, address: marker.address!);
  }

  set address(PudoAddressMarker? newVal) {
    _address = newVal;
    notifyListeners();
  }

  // ************ Navigation *****
  onSendClick(BuildContext context, PudoProfile? pudoModel) {}

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

  pickFile(BuildContext context) async {
    showImageChoice(context, (value) {
      if (value != null) {
        image = value;
      }
    });
  }

  List<GeoMarker> _addresses = [];

  List<GeoMarker> get addresses => _addresses;

  set addresses(List<GeoMarker> newVal) {
    _addresses = newVal;
    notifyListeners();
  }

  bool _isOpenListAddress = false;

  bool get isOpenListAddress => _isOpenListAddress;

  set isOpenListAddress(bool newVal) {
    _isOpenListAddress = newVal;
    notifyListeners();
  }

  TextEditingController addressController = TextEditingController();

  Timer _debounce = Timer(const Duration(days: 1), () {});

  String lastSearchQuery = "";

  void onSearchChanged(String query) {
    if (query != lastSearchQuery && query != (address?.address.label ?? "")) {
      address = null;
      if (_debounce.isActive) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        fetchSuggestions(query);
      });
    }
  }

  Future<void> fetchSuggestions(String val) async {
    if (val.trim().isNotEmpty) {
      var res = await NetworkManager.instance.getAddresses(text: val, precise: true);
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

  RegistrationPudoModel buildRequest() {
    return RegistrationPudoModel(profilePic: image, businessName: name, publicPhoneNumber: phoneNumber, addressMarker: address!, rewardPolicy: null);
  }
}
