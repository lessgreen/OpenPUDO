// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:qui_green/resources/routes_enum.dart';

class ThanksControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation *****
  onOkClick(BuildContext context) {
    Navigator.pop(context);
  }

  onPersonalDataBusinessClick(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.personalDataBusiness);
  }
}
