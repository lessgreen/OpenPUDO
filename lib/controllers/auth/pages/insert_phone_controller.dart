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
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
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

  bool get validatePhoneNumber {
    //RegExp regExp = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
    if (_phoneNumberValue.isEmpty) {
      return false;
    }
    /* else if (!regExp.hasMatch(_phoneNumberValue)) {
      return false;
    }*/
    return true;
  }

  Future<void> sendRequest() async {
    OPBaseResponse response = await NetworkManager.instance
        .registerUser(phoneNumber: _phoneNumberValue);
    if(response.returnCode==0) {
      Navigator.of(context).pushReplacementNamed(Routes.confirmPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO implement provider
    return KeyboardVisibilityBuilder(
      builder: (context, child, isKeyboardVisible) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
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
                    onTap: () {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(
                  height: Dimension.paddingL,
                ),
                SvgPicture.asset(ImageSrc.smsArt,
                    semanticsLabel: 'Art Background'),
                const Spacer(),
                AnimatedCrossFade(
                  crossFadeState: isKeyboardVisible
                      ? CrossFadeState.showSecond
                      : validatePhoneNumber
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                  secondChild: const SizedBox(),
                  firstChild: MainButton(
                    onPressed: sendRequest,
                    text: 'Invia',
                  ),
                  duration: const Duration(milliseconds: 150),
                ),
                // ScrollableSuggestions(
                //   keyboardVisible: isKeyboardVisible,
                //   dismissOnDrag: false,
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
