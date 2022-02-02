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
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/user_preferences.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class HomeRegistrationCompleteControllerViewModel extends ChangeNotifier {
  Function(dynamic)? showErrorDialog;
  bool _showNumber = true;

  bool get showNumber => _showNumber;

  updateShowNumberPreference(bool newValue) {
    _showNumber = newValue;
    notifyListeners();
    NetworkManager.instance.updateUserPreferences(showNumber: newValue).then(
      (value) {
        if (value is UserPreferences) {
          _showNumber = value.showPhoneNumber;
          notifyListeners();
        }
      },
    ).catchError(
      (onError) => showErrorDialog?.call(onError),
    );
  }

  onGoHomeClick(BuildContext context) async {
    await NetworkManager.instance
        .updateUserPreferences(showNumber: _showNumber)
        .then(
      (value) {
        Provider.of<CurrentUser>(context, listen: false).refresh();
      },
    ).catchError(
      (onError) =>
          SAAlertDialog.displayAlertWithClose(context, "Error", onError),
    );
  }

  onInstructionsClick(BuildContext context, PudoProfile? pudoModel) {
    Navigator.of(context).pushNamed(Routes.instruction, arguments: pudoModel);
  }
}
