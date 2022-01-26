//
//   confirm_phone_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Tue Jan 04 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/commons/widgets/sascaffold.dart';
import 'package:qui_green/commons/widgets/text_field_button.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class ConfirmPhoneController extends StatefulWidget {
  const ConfirmPhoneController({Key? key,required this.phoneNumber}) : super(key: key);
  final String phoneNumber;
  @override
  _ConfirmPhoneControllerState createState() => _ConfirmPhoneControllerState();
}

class _ConfirmPhoneControllerState extends State<ConfirmPhoneController> {
  final FocusNode _confirmValueFocus = FocusNode();
  String _confirmValue = "";

  bool get validateOtp {
    if (_confirmValue.isEmpty) {
      return false;
    }
    return true;
  }

  void retryOtp() {
    NetworkManager.instance
        .sendPhoneAuth(phoneNumber: widget.phoneNumber)
        .catchError((onError) {
      SAAlertDialog.displayAlertWithClose(context, "Error", onError);
    });
  }

  void sendOtp() {
    NetworkManager.instance
        .login(
            login: widget.phoneNumber, password: _confirmValue)
        .then((value) {
      NetworkManager.instance.getMyProfile().then((value) {
        if (value is UserProfile) {
          //user exists
          Provider.of<CurrentUser>(context, listen: false).user = value;
          Navigator.of(context).pushReplacementNamed(Routes.home);
        } else if (value == null) {
          //user doesn't exists
          Navigator.of(context).pushReplacementNamed(Routes.aboutYou);
        } else {
          SAAlertDialog.displayAlertWithClose(
              context, "Error", "Generic error");
        }
      }).catchError((onError) =>
          SAAlertDialog.displayAlertWithClose(context, "Error", onError));
    }).catchError((onError) =>
            SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  @override
  Widget build(BuildContext context) {
    //TODO implement provider
    return KeyboardVisibilityBuilder(
        builder: (context, child, isKeyboardVisible) {
      return WillPopScope(
        onWillPop: () async => false,
        child: SAScaffold(
          isLoading: NetworkManager.instance.networkActivity,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            leading: const SizedBox(),
          ),
          body: Column(
            children: [
              Center(
                child: Text(
                  'Inserisci il codice di conferma',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Center(
                  child: Text(
                    'Inserisci il codice di conferma che \n ti abbiamo appena inviato',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).primaryColor))),
                  autofocus: false,
                  focusNode: _confirmValueFocus,
                  suffix: TextFieldButton(
                    onPressed: () {
                      setState(() {
                        _confirmValueFocus.unfocus();
                      });
                    },
                    text: isKeyboardVisible ? 'DONE' : "",
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onChanged: (newValue) {
                    setState(() {
                      _confirmValue = newValue;
                    });
                  },
                  onTap: () {
                    setState(() {});
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "non hai ricevuto il codice?",
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                    InkWell(
                        onTap: retryOtp,
                        splashColor: Colors.transparent,
                        child: Text("inviane un'altro",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryColorDark)))
                  ],
                ),
              ),
              const Spacer(),
              SvgPicture.asset(ImageSrc.smsArt,
                  semanticsLabel: 'Art Background'),
              const Spacer(),
              AnimatedCrossFade(
                crossFadeState: isKeyboardVisible
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                secondChild: const SizedBox(),
                firstChild: MainButton(
                  onPressed: sendOtp,
                  text: 'Invia',
                  enabled: validateOtp,
                ),
                duration: const Duration(milliseconds: 150),
              ),
            ],
          ),
        ),
      );
    });
  }
}
