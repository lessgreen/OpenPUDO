import 'package:flutter/material.dart';
import 'package:qui_green/resources/routes_enum.dart';

class ProfileControllerViewModel extends ChangeNotifier {
  goToPudos(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.pudoList);
  }
}
