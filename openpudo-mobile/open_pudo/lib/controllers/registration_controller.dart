//
//  RegistrationController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/formfield_validators.dart';
import 'package:open_pudo/commons/sabutton.dart';
import 'package:open_pudo/commons/scrollkeyboard_closer.dart';
import 'package:open_pudo/models/base_response.dart';
import 'package:open_pudo/singletons/network.dart';
import 'package:open_pudo/commons/Localization.dart';

class RegistrationController extends StatefulWidget {
  RegistrationController({Key? key}) : super(key: key);

  @override
  _RegistrationControllerState createState() => _RegistrationControllerState();
}

class _RegistrationControllerState extends State<RegistrationController> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  FocusNode _emailNode = FocusNode();
  late String _password;
  FocusNode _passwordNode = FocusNode();
  String? _phone;
  FocusNode _phoneNode = FocusNode();
  String? _username;
  FocusNode _usernameNode = FocusNode();
  late String _firstName;
  FocusNode _firstNameNode = FocusNode();
  late String _lastName;
  FocusNode _lastNameNode = FocusNode();
  String? _ssn;
  FocusNode _ssnNode = FocusNode();
  late String _vat;
  FocusNode _vatNode = FocusNode();
  late String _businessName;
  FocusNode _businessNameNode = FocusNode();

  int _selectedSegment = 0;

  void registerNewPudoUser() {
    NetworkManager()
        .registerPudo(
      password: _password,
      firstName: _firstName,
      lastName: _lastName,
      phoneNumber: _phone,
      username: _username,
      email: _email,
      businessName: _businessName,
      vat: _vat,
    )
        .then(
      (value) {
        if (value is OPBaseResponse) {
          if (value.returnCode == 0) {
            print("success: $value");
            SAAlertDialog.displayAlertWithClose(
              context,
              "thanksTitle".localized(context, "registrationScreen"),
              "registrationSuccess".localized(context, "registrationScreen"),
            );
            Navigator.of(context).pop();
          } else if (value.message != null) {
            throw value.message!;
          } else {
            SAAlertDialog.displayAlertWithClose(context, "errore", value);
          }
        } else {
          throw "Network Error";
        }
      },
    ).catchError(
      (onError) {
        print("catch error: $onError");
        SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, 'alert'), onError);
      },
    );
  }

  void registerNewUser() {
    NetworkManager()
        .registerUser(
      password: _password,
      firstName: _firstName,
      lastName: _lastName,
      phoneNumber: _phone,
      username: _username,
      email: _email,
      ssn: _ssn,
    )
        .then(
      (value) {
        if (value is OPBaseResponse) {
          if (value.returnCode == 0) {
            print("success: $value");
            SAAlertDialog.displayAlertWithClose(
              context,
              "thanksTitle".localized(context, "registrationScreen"),
              "registrationSuccess".localized(context, "registrationScreen"),
            );
            Navigator.of(context).pop();
          } else if (value.message != null) {
            throw value.message!;
          } else {
            SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, "alert"), value);
          }
        } else {
          throw "Network Error";
        }
      },
    ).catchError(
      (onError) {
        print("catch error: $onError");
        SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, 'alert'), onError);
      },
    );
  }

  bool _validateMandatoryFields() {
    if ((_email != null && _email!.isValidEmail()) || (_phone != null && _phone!.isValidPhoneNumber()) || (_username != null && _username!.length > 0)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          'navTitle'.localized(context, "registrationScreen"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: ScrollKeyboardCloser(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 32),
                  child: Text(
                    "subHeading".localized(context, "registrationScreen"),
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
                MaterialSegmentedControl(
                  children: <int, Widget>{
                    0: Text("iamuser".localized(context, "registrationScreen")),
                    1: Text("iampudo".localized(context, "registrationScreen")),
                  },
                  selectionIndex: _selectedSegment,
                  borderColor: Theme.of(context).primaryColor,
                  selectedColor: Theme.of(context).primaryColor,
                  unselectedColor: Theme.of(context).backgroundColor,
                  onSegmentChosen: (index) {
                    setState(() {
                      _selectedSegment = index as int;
                    });
                  },
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          enableSuggestions: false,
                          focusNode: _emailNode,
                          decoration: InputDecoration(hintText: 'emailPlaceholder'.localized(context, "registrationScreen")),
                          validator: (value) {
                            if (_validateMandatoryFields()) return null;
                            return value!.isValidEmail() ? null : 'invalidEmail'.localized(context, "registrationScreen");
                          },
                          onChanged: (value) {
                            _email = value;
                          },
                        ),
                        TextFormField(
                          focusNode: _passwordNode,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          textCapitalization: TextCapitalization.none,
                          decoration: InputDecoration(hintText: 'passwordPlaceholder'.localized(context, "registrationScreen")),
                          validator: (value) {
                            return value!.isValidPassword() ? null : 'invalidPassword'.localized(context, "registrationScreen");
                          },
                          onChanged: (value) {
                            _password = value;
                          },
                        ),
                        TextFormField(
                          focusNode: _phoneNode,
                          keyboardType: TextInputType.phone,
                          autocorrect: false,
                          enableSuggestions: false,
                          textCapitalization: TextCapitalization.none,
                          decoration: InputDecoration(hintText: 'phonePlaceholder'.localized(context, "registrationScreen")),
                          validator: (value) {
                            if (_validateMandatoryFields()) return null;
                            return value!.isValidPhoneNumber() ? null : 'invalidPhone'.localized(context, "registrationScreen");
                          },
                          onChanged: (value) {
                            _phone = value;
                          },
                        ),
                        TextFormField(
                          focusNode: _usernameNode,
                          autocorrect: false,
                          enableSuggestions: false,
                          textCapitalization: TextCapitalization.none,
                          decoration: InputDecoration(hintText: 'usernamePlaceholder'.localized(context, "registrationScreen")),
                          onChanged: (value) {
                            _username = value;
                          },
                          validator: (value) {
                            if (_validateMandatoryFields()) return null;
                            return value!.length > 0 ? null : 'invalidUsername'.localized(context, "registrationScreen");
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                          child: TextFormField(
                            focusNode: _firstNameNode,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(hintText: 'firstNamePlaceholder'.localized(context, "registrationScreen")),
                            onChanged: (value) {
                              _firstName = value;
                            },
                            validator: (value) {
                              return value!.length > 0 ? null : 'invalidFirstName'.localized(context, "registrationScreen");
                            },
                          ),
                        ),
                        TextFormField(
                          focusNode: _lastNameNode,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(hintText: 'lastNamePlaceholder'.localized(context, "registrationScreen")),
                          onChanged: (value) {
                            _lastName = value;
                          },
                          validator: (value) {
                            return value!.length > 0 ? null : 'invalidLastName'.localized(context, "registrationScreen");
                          },
                        ),
                        _selectedSegment == 0
                            ? TextFormField(
                                autocorrect: false,
                                enableSuggestions: false,
                                textCapitalization: TextCapitalization.none,
                                focusNode: _ssnNode,
                                decoration: InputDecoration(hintText: 'ssnPlaceholder'.localized(context, "registrationScreen")),
                                onChanged: (value) {
                                  _ssn = value;
                                },
                                // validator: (value) {
                                //   return value!.length > 0 ? null : 'invalidSSN'.localized(context, "registrationScreen");
                                // },
                              )
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      textCapitalization: TextCapitalization.words,
                                      focusNode: _businessNameNode,
                                      decoration: InputDecoration(hintText: "pudoNamePlaceholder".localized(context, "registrationScreen")),
                                      onChanged: (value) {
                                        _businessName = value;
                                      },
                                      validator: (value) {
                                        return value!.length > 0 ? null : 'invalidBusinessName'.localized(context, "registrationScreen");
                                      },
                                    ),
                                    TextFormField(
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      textCapitalization: TextCapitalization.none,
                                      focusNode: _vatNode,
                                      decoration: InputDecoration(hintText: 'pivaPlaceholder'.localized(context, "registrationScreen")),
                                      onChanged: (value) {
                                        _vat = value;
                                      },
                                      validator: (value) {
                                        return value!.length > 0 ? null : 'invalidVAT'.localized(context, "registrationScreen");
                                      },
                                    )
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 90),
                  child: SAButton(
                    fixedSize: Size.fromHeight(48),
                    borderRadius: 24,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _selectedSegment == 0 ? registerNewUser() : registerNewPudoUser();
                      }
                    },
                    label: 'registrati'.localized(context, 'registrationScreen'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
