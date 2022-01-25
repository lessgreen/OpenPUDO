import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class RegistrationCompleteControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation *****
  onOkClick(BuildContext context) async {
    await NetworkManager.instance.updateUserPreferences(showNumber: _showNumber);
    Provider.of<CurrentUser>(context,listen: false).refresh();
  }

  onInstructionsClick(BuildContext context, PudoProfile? pudoModel) {
    Navigator.of(context)
        .pushReplacementNamed(Routes.instruction, arguments: pudoModel);
  }

  bool _showNumber = true;

  bool get showNumber => _showNumber;

  set showNumber(bool newVal) {
    _showNumber = newVal;
    notifyListeners();
  }
}
