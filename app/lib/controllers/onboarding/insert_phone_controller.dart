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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/models/base_response.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/commons/utilities/localization.dart';

class InsertPhoneController extends StatefulWidget {
  const InsertPhoneController({Key? key}) : super(key: key);

  @override
  _InsertPhoneControllerState createState() => _InsertPhoneControllerState();
}

class _InsertPhoneControllerState extends State<InsertPhoneController> with ConnectionAware {
  final FocusNode _phoneNumber = FocusNode();
  String _phoneNumberValue = "";
  String _initialCountry = 'IT';
  PhoneNumber _number = PhoneNumber(isoCode: 'IT');
  bool _buttonEnabled = false;
  final TextEditingController _phoneTextController = TextEditingController();

  String _getCountryISOCode() {
    final WidgetsBinding? instance = WidgetsBinding.instance;
    if (instance != null) {
      final List<Locale> systemLocales = instance.window.locales;
      String? isoCountryCode = systemLocales.first.countryCode;
      if (isoCountryCode != null) {
        return isoCountryCode;
      } else {
        throw ("Unable to get Country ISO code");
      }
    } else {
      throw ("Unable to get Country ISO code");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initialCountry = _getCountryISOCode();
      _number = PhoneNumber(isoCode: _initialCountry);
    });
  }

  Future<void> sendRequest() async {
    NetworkManager.instance.sendPhoneAuth(phoneNumber: _phoneNumberValue).then((response) {
      if (response is OPBaseResponse && response.returnCode == 0) {
        Navigator.of(context).pushReplacementNamed(Routes.confirmPhone, arguments: _phoneNumberValue);
      } else {
        throw response;
      }
    }).catchError((onError) {
      SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError);
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
            body: Stack(
              children: [
                SvgPicture.asset(ImageSrc.insertPhoneArt, semanticsLabel: 'Art Background'),
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
                      child: Stack(
                        children: [
                          InternationalPhoneNumberInput(
                              searchBoxDecoration: InputDecoration(labelText: 'insertCountry'.localized(context, 'InsertPhoneControllerState')),
                              hintText: 'phoneNumber'.localized(context, 'InsertPhoneControllerState'),
                              errorMessage: 'wrongPhoneNumber'.localized(context, 'InsertPhoneControllerState'),
                              focusNode: _phoneNumber,
                              spaceBetweenSelectorAndTextField: 0,
                              onInputChanged: (PhoneNumber number) {
                                _phoneNumberValue = number.phoneNumber ?? '';
                              },
                              onInputValidated: (bool value) {
                                setState(() {
                                  _buttonEnabled = value;
                                });
                              },
                              selectorConfig: const SelectorConfig(
                                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                              ),
                              ignoreBlank: false,
                              autoValidateMode: AutovalidateMode.onUserInteraction,
                              selectorTextStyle: const TextStyle(color: Colors.black),
                              initialValue: _number,
                              textFieldController: _phoneTextController,
                              formatInput: true,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                          Visibility(
                            visible: _phoneNumber.hasFocus,
                            child: Positioned(
                              right: -15,
                              child: MaterialButton(
                                child: Text(
                                  'doneButton'.localized(context),
                                  style: TextStyle(color: Theme.of(context).primaryColor),
                                ),
                                onPressed: () {
                                  _phoneNumber.unfocus();
                                  if (_buttonEnabled) {
                                    sendRequest();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    MainButton(
                      onPressed: sendRequest,
                      text: 'submitButton'.localized(context),
                      enabled: _buttonEnabled,
                    ),
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
