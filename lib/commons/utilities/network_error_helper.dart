import 'package:flutter/cupertino.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/localization.dart';

class NetworkErrorHelper {
  static void helper(BuildContext context, dynamic value) {
    if (value is ErrorDescription) {
      SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), value);
    } else {
      SAAlertDialog.displayAlertWithClose(
        context,
        'genericErrorTitle'.localized(context, 'general'),
        'genericErrorDescription'.localized(context, 'general'),
      );
    }
  }
}
