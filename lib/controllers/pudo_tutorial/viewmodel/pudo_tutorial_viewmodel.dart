import 'package:flutter/material.dart';
import 'package:qui_green/resources/routes_enum.dart';

class PudoTutorialViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation *****
  onEndClick(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.thanks);
  }
  // ************ Location *******
}
