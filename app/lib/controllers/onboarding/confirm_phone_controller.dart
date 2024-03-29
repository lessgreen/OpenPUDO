/*
 OpenPUDO - PUDO and Micro-delivery software for Last Mile Collaboration
 Copyright (C) 2020-2022 LESS SRL - https://less.green

 This file is part of OpenPUDO software.

 OpenPUDO is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License version 3
 as published by the Copyright Owner.

 OpenPUDO is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License version 3 for more details.

 You should have received a copy of the GNU Affero General Public License
 version 3 published by the Copyright Owner along with OpenPUDO.  
 If not, see <https://github.com/lessgreen/OpenPUDO>.
*/

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/commons/utilities/network_error_helper.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/widgets/text_field_button.dart';

class ConfirmPhoneController extends StatefulWidget {
  const ConfirmPhoneController({Key? key, required this.phoneNumber}) : super(key: key);
  final String phoneNumber;

  @override
  _ConfirmPhoneControllerState createState() => _ConfirmPhoneControllerState();
}

class _ConfirmPhoneControllerState extends State<ConfirmPhoneController> with ConnectionAware {
  final FocusNode _confirmValueFocus = FocusNode();
  String _confirmValue = "";

  bool get validateOtp {
    if (_confirmValue.isEmpty) {
      return false;
    }
    return true;
  }

  void retryOtp() {
    NetworkManager.instance.sendPhoneAuth(phoneNumber: widget.phoneNumber).catchError((onError) {
      SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError);
    });
  }

  void sendOtp() {
    NetworkManager.instance.login(login: widget.phoneNumber, password: _confirmValue).then((value) {
      switch (NetworkManager.instance.accessTokenAccess) {
        case "customer":
          Provider.of<CurrentUser>(context, listen: false).refresh(context);
          break;
        case "pudo":
          Provider.of<CurrentUser>(context, listen: false).refresh(context);
          break;
        case "guest":
          Navigator.of(context).pushReplacementNamed(Routes.aboutYou, arguments: {'phoneNumber': widget.phoneNumber});
          break;
        default:
          NetworkErrorHelper.helper(context, value);
          break;
      }
    }).catchError((onError) {
      SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, child, isKeyboardVisible) {
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
          body: Stack(
            children: [
              SvgPicture.asset(ImageSrc.smsArt),
              Column(
                children: [
                  Center(
                    child: Text(
                      'mainLabel'.localized(context),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Center(
                      child: Text(
                        'secondaryLabel'.localized(context),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: CupertinoTextField(
                      placeholder: "inserPinPlaceholder".localized(context, "ConfirmPhoneControllerState"),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                      autofocus: false,
                      focusNode: _confirmValueFocus,
                      autofillHints: Platform.isIOS ? const [AutofillHints.oneTimeCode] : null,
                      suffix: TextFieldButton(
                        onPressed: () {
                          setState(() {
                            _confirmValueFocus.unfocus();
                            if (validateOtp) {
                              sendOtp();
                            }
                          });
                        },
                        text: isKeyboardVisible ? 'doneButton'.localized(context) : "",
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
                          'hintText'.localized(context),
                          style: Theme.of(context).textTheme.captionItalic,
                        ),
                        GestureDetector(
                          onTap: retryOtp,
                          child: Text(
                            'hintButton'.localized(context),
                            style: Theme.of(context).textTheme.bodyTextBoldAccent,
                          ),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  MainButton(
                    onPressed: sendOtp,
                    text: 'submitButton'.localized(context),
                    enabled: validateOtp,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
