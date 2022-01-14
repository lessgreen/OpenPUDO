import 'package:flutter/material.dart';
import 'package:qui_green/resources/routes_enum.dart';

class MapsControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation ***********
  onPudoClick(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.pudoDetail);
  }
}
