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

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qui_green/commons/utilities/print_helper.dart';
import 'package:qui_green/models/extra_info.dart';
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/registration_pudo_model.dart';
import 'package:qui_green/models/registration_pudo_request.dart';
import 'package:qui_green/models/reward_option.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class PudoRegistrationPreviewControllerViewModel extends ChangeNotifier {
  PudoRegistrationPreviewControllerViewModel(PudoProfile profile) {
    businessNameController.text = profile.businessName;
    phoneController.text = profile.publicPhoneNumber ?? "";
    addressController.text = profile.address?.label ?? "";
  }

  late RegistrationPudoModel dataModel;

  // ************ Navigation *****
  onSendClick(BuildContext context, RegistrationPudoModel requestModel) {
    Navigator.of(context).pushReplacementNamed(Routes.pudoRegistrationPreview, arguments: requestModel.copyWith(rewardPolicy: dataSource));
  }

  bool _editEnabled = false;

  bool get editEnabled => _editEnabled;

  void handleEdit() {
    if (!_editEnabled) {
      _editEnabled = true;
      notifyListeners();
    } else {
      _editEnabled = false;
      notifyListeners();
      //TODO implement proper save
      /*if (isValid) {
        _editEnabled = false;
        notifyListeners();
      }*/
    }
  }

  TextEditingController businessNameController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  List<RewardOption> _dataSource = [];

  List<RewardOption> get dataSource => _dataSource;

  set dataSource(List<RewardOption> newVal) {
    _dataSource = newVal;
    notifyListeners();
  }

  bool get mandatoryFulfilled {
    for (var aRow in dataSource) {
      if ((aRow.checked ?? false) && aRow.extraInfo != null && aRow.extraInfo!.mandatoryValue == true) {
        switch (aRow.extraInfo!.type) {
          case ExtraInfoType.text:
            if (aRow.extraInfo!.value == null) {
              return false;
            }
            break;
          case ExtraInfoType.decimal:
            if (aRow.extraInfo!.value == null) {
              return false;
            }
            break;
          case ExtraInfoType.select:
            if (aRow.extraInfo!.values == null) {
              return true;
            } else {
              for (var anOption in aRow.extraInfo!.values!) {
                if (anOption.checked == true) {
                  return true;
                }
              }
              return false;
            }
        }
      }
    }
    return true;
  }

  bool get isExclusiveSelected {
    for (var aRow in dataSource) {
      if ((aRow.exclusive ?? false) && (aRow.checked ?? false)) {
        return true;
      }
    }
    return false;
  }

  void onValueChange(int index, bool value) {
    if (isExclusiveSelected) {
      if (dataSource[index].exclusive == false) {
        return;
      }
    }
    dataSource[index].checked = value;
    notifyListeners();
  }

  void onSubSelectValueChange(int rowIndex, int optionIndex, bool value) {
    dataSource[rowIndex].extraInfo?.values?[optionIndex].checked = value;
    notifyListeners();
  }

  void onTextChange(int index, String value) {
    RewardOption? aRow = (index < dataSource.length) ? dataSource[index] : null;
    if (aRow == null || aRow.extraInfo == null) {
      return;
    }
    if (aRow.extraInfo!.type == ExtraInfoType.text || aRow.extraInfo!.type == ExtraInfoType.decimal) {
      aRow.extraInfo!.value = value;
      notifyListeners();
    }
  }

  void onSubTextChange(int rowIndex, int optionIndex, String value) {
    RewardOption? aRow = (rowIndex < dataSource.length) ? dataSource[rowIndex] : null;
    if (aRow == null || aRow.extraInfo == null) {
      return;
    }

    if (aRow.extraInfo == null || aRow.extraInfo!.values == null || optionIndex >= aRow.extraInfo!.values!.length) {
      return;
    }
    ExtraInfoSelectItem? subItem = aRow.extraInfo?.values?[optionIndex];
    if (subItem == null) {
      return;
    }
    if (subItem.extraInfo!.type == ExtraInfoType.text || subItem.extraInfo!.type == ExtraInfoType.decimal) {
      subItem.extraInfo!.value = value;
      notifyListeners();
    }
  }

  bool checkExtraInfo(ExtraInfo? info) {
    if (info != null) {
      switch (info.type) {
        case ExtraInfoType.text:
          if (info.value != null) {
            if ((info.value as String).isNotEmpty) {
              return true;
            }
          }
          break;
        case ExtraInfoType.decimal:
          if (info.value != null) {
            if ((info.value as String) != "0") {
              return true;
            }
          }
          break;
        case ExtraInfoType.select:
          if (info.values != null) {
            if (info.values is List<ExtraInfoSelectItem>) {
              for (ExtraInfoSelectItem item in info.values!) {
                if (item.checked ?? false) {
                  if (item.extraInfo != null) {
                    return checkExtraInfo(item.extraInfo);
                  } else {
                    return true;
                  }
                }
              }
            }
          }
      }
      return false;
    } else {
      return false;
    }
  }

  bool checkIfOptionIsValid(RewardOption option) {
    if (option.checked ?? false) {
      if (option.extraInfo != null) {
        if (checkExtraInfo(option.extraInfo)) {
          return true;
        }
      } else {
        return true;
      }
    }
    return false;
  }

  String _name = "";

  String get name => _name;

  set name(String newVal) {
    _name = newVal;
    notifyListeners();
  }

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

  get isValid {
    if (_image == null) {
      return false;
    }
    if (_name.isEmpty) {
      return false;
    }
    if (_phoneNumber.isEmpty) {
      return false;
    }
    if (_address == null) {
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
  //onSendClick(BuildContext context, PudoProfile? pudoModel) {}

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.media);
    if (result != null) {
      try {
        File file = File(result.files.first.path ?? "");
        image = file;
      } catch (e) {
        //showErrorDialog?.call(e.toString());
        safePrint(e.toString());
      }
    } else {
      // User canceled the picker
    }
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
      var res = await NetworkManager.instance.getAddresses(text: val);
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

  void goToInstructions(BuildContext context, PudoProfile profile) {
    Navigator.of(context).pushReplacementNamed(Routes.pudoTutorial, arguments: profile);
  }
}
