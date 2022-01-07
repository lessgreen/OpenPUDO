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
import 'package:qui_green/commons/keyboard_visibility.dart';

class InsertPhoneController extends StatefulWidget {
  const InsertPhoneController({Key? key}) : super(key: key);

  @override
  _InsertPhoneControllerState createState() => _InsertPhoneControllerState();
}

class _InsertPhoneControllerState extends State<InsertPhoneController> {
  final FocusNode _phoneNumber = FocusNode();
  String _phoneNumberValue = "";

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, child, isKeyboardVisible) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              leading: const SizedBox(),
            ),
            body: Stack(
              children: [
                PositionedDirectional(
                  top: 200,
                  child: SvgPicture.asset('assets/smsArt.svg', semanticsLabel: 'Art Background'),
                ),
                isKeyboardVisible
                    ? const SizedBox()
                    : PositionedDirectional(
                        start: 20,
                        end: 20,
                        bottom: 50,
                        child: TextButton(
                          style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(const Size(200, 30)),
                              padding: MaterialStateProperty.all(const EdgeInsets.all(18)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(34.0),
                                  side: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                              ),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.bodyText2),
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)),
                          child: const Text('Invia'),
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/confirmPhone');
                          },
                        ),
                      ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Inserisci il tuo numero telefonico',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Ti invieremo un sms di conferma\nper assicurarci che sei tu.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: CupertinoTextField(
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                        autofocus: false,
                        focusNode: _phoneNumber,
                        suffix: TextButton(
                          child: Text(_phoneNumber.hasFocus ? 'DONE' : ''),
                          onPressed: _phoneNumber.hasFocus
                              ? () {
                                  setState(() {
                                    _phoneNumber.unfocus();
                                  });
                                }
                              : null,
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        onChanged: (newValue) {
                          _phoneNumberValue = newValue;
                        },
                        onTap: () {
                          setState(() {});
                        },
                      ),
                    ),
                    // ScrollableSuggestions(
                    //   keyboardVisible: isKeyboardVisible,
                    //   dismissOnDrag: false,
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
