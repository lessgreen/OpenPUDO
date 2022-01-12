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
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/commons/widgets/text_field_button.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

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
                    _confirmValue = newValue;
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
                    : CrossFadeState.showFirst,
                secondChild: const SizedBox(),
                firstChild: MainButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(Routes.aboutYou);
                  },
                  text: 'Invia',
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
