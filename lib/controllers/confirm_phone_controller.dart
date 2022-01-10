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
import 'package:qui_green/resources/res.dart';

class ConfirmPhoneController extends StatefulWidget {
  const ConfirmPhoneController({Key? key}) : super(key: key);

  @override
  _ConfirmPhoneControllerState createState() => _ConfirmPhoneControllerState();
}

class _ConfirmPhoneControllerState extends State<ConfirmPhoneController> {
  final FocusNode _confirmValueFocus = FocusNode();
  String _confirmValue = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: const SizedBox(),
        ),
        body: Stack(
          children: [
            Center(
              child: SvgPicture.asset(ImageSrc.smsArt,
                  semanticsLabel: 'Art Background'),
            ),
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              shrinkWrap: false,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Inserisci il codice di conferma',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(letterSpacing: 0.6),
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
                          'Inserisci il codice di conferma che\nti abbiamo appena inviato.',
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
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Theme.of(context).primaryColor))),
                    focusNode: _confirmValueFocus,
                    suffix: TextButton(
                      child: Text(_confirmValueFocus.hasFocus ? 'DONE' : ''),
                      onPressed: _confirmValueFocus.hasFocus
                          ? () {
                              setState(() {
                                _confirmValueFocus.unfocus();
                              });
                            }
                          : null,
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onChanged: (newValue) {
                      _confirmValue = newValue;
                    },
                    onTap: () {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            PositionedDirectional(
              start: 20,
              end: 20,
              bottom: 50,
              child: TextButton(
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(200, 30)),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(18)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34.0),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    textStyle: MaterialStateProperty.all(
                        Theme.of(context).textTheme.bodyText2),
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor)),
                child: const Text('Invia'),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/aboutYou');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
