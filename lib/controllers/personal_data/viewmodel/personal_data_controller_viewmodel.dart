import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class PersonalDataControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation *****
  onSendClick(BuildContext context, PudoProfile? pudoModel) async {
    if (image != null) {
      await NetworkManager.instance.photoUpload(image!);
    }
    if(_name.isNotEmpty) {
      await NetworkManager.instance
          .setMyProfile(UserProfile(firstName: name, lastName: surname));
    }
    Navigator.of(context).pushReplacementNamed(Routes.registrationComplete,
        arguments: pudoModel);
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

  String _name = "";
  String _surname = "";

  String get name => _name;

  String get surname => _surname;

  set name(String newVal) {
    _name = newVal;
    notifyListeners();
  }

  set surname(String newVal) {
    _surname = newVal;
    notifyListeners();
  }

  get isValid {
    if(image!=null){
      return true;
    }
    if (_name.isEmpty) {
      return false;
    }
    if (_surname.isEmpty) {
      return false;
    }
    return true;
  }

  File? _image;

  File? get image => _image;

  set image(File? newVal) {
    _image = newVal;
    notifyListeners();
  }

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (result != null) {
      try {
        File file = File(result.files.first.path ?? "");
        image = file;
      } catch (e) {
        print(e);
      }
    } else {
      // User canceled the picker
    }
  }
}
