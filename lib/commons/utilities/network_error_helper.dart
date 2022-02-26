import 'package:flutter/cupertino.dart';
import 'package:qui_green/commons/alert_dialog.dart';

class NetworkErrorHelper {
  static void helper(BuildContext context, dynamic value) {
    if (value is ErrorDescription) {
      SAAlertDialog.displayAlertWithClose(context, "Error", value);
    } else {
      SAAlertDialog.displayAlertWithClose(context, "Error", "Qualcosa è andato storto");
    }
  }
}
