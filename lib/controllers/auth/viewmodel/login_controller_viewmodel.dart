import 'package:flutter/material.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network.dart';

class LoginControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation *****
  onAccessClick(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.insertPhone);
  }
}
