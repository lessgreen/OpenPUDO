//
//   insert_phone_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Tue Jan 04 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/formfields_validators.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/commons/widgets/sascaffold.dart';
import 'package:qui_green/commons/widgets/text_field_button.dart';
import 'package:qui_green/models/base_response.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class InsertPhoneController extends StatefulWidget {
  const InsertPhoneController({Key? key}) : super(key: key);

  @override
  _InsertPhoneControllerState createState() => _InsertPhoneControllerState();
}

class _InsertPhoneControllerState extends State<InsertPhoneController> {
  final FocusNode _phoneNumber = FocusNode();
  String _phoneNumberValue = "";

  Future<void> sendRequest() async {
    //TODO create a national phone prefix selector, the be needs it,for now lets presume it's all italy
    NetworkManager.instance
        .sendPhoneAuth(phoneNumber: "+39$_phoneNumberValue")
        .then((response) {
      if (response is OPBaseResponse && response.returnCode == 0) {
        Navigator.of(context).pushReplacementNamed(Routes.confirmPhone,arguments: "+39$_phoneNumberValue");
      } else {
        throw response;
      }
    }).catchError((onError) {
      SAAlertDialog.displayAlertWithClose(context, "Error", onError);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    'Inserisci il tuo numero telefonico',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Center(
                    child: Text(
                      'Ti invieremo un sms di conferma\nper assicurarci che sei tu.',
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
                    focusNode: _phoneNumber,
                    suffix: TextFieldButton(
                      onPressed: () {
                        setState(() {
                          _phoneNumber.unfocus();
                        });
                      },
                      text: isKeyboardVisible ? 'DONE' : "",
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onChanged: (newValue) {
                      setState(() {
                        _phoneNumberValue = newValue;
                      });
                    },
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
                    onPressed: sendRequest,
                    text: 'Invia',
                    enabled: _phoneNumberValue.isValidPhoneNumber(),
                  ),
                  duration: const Duration(milliseconds: 150),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
