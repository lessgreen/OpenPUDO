//
//  LoginController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sabutton.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/commons/scrollkeyboard_closer.dart';
import 'package:open_pudo/main.dart';
import 'package:open_pudo/models/base_response.dart';
import 'package:open_pudo/singletons/current_user.dart';
import 'package:open_pudo/singletons/network.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginController extends StatefulWidget {
  LoginController({Key? key}) : super(key: key);

  @override
  _LoginControllerState createState() => _LoginControllerState();
}

class _LoginControllerState extends State<LoginController> {
  final _formKey = GlobalKey<FormState>();
  FocusNode _usernameNode = FocusNode();
  FocusNode _passwordNode = FocusNode();
  late String _username;
  late String _password;

  @override
  void dispose() {
    needsLogin.value = false;
    super.dispose();
  }

  _loginDidPress() {
    _usernameNode.unfocus();
    _passwordNode.unfocus();
    NetworkManager().login(login: _username, password: _password).then((value) {
      if (value is OPBaseResponse) {
        if (value.returnCode == 0) {
          print("success: $value");
          NetworkManager().getMyProfile().then((profile) {
            Provider.of<CurrentUser>(context, listen: false).user = profile;
            Navigator.of(context).pop();
          }).catchError((onError) => throw onError);
        } else if (value.message != null) {
          throw value.message!;
        } else {
          SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, "alert"), value);
        }
      } else {
        throw "Network Error";
      }
    }).catchError((onError) {
      print("catch error: $onError");
      SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, 'alert'), onError);
    });
  }

  _registerDidPress() {
    Navigator.of(context, rootNavigator: false).pushNamed('/registration');
  }

  _passwordForgotDidPress() {
    launch('https://tools.quigreen.it/recover.html');
  }

  @override
  Widget build(BuildContext context) {
    return SAScaffold(
      isLoading: NetworkManager().networkActivity,
      appBar: AppBar(
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text("navTitle".localized(context, 'loginScreen')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ScrollKeyboardCloser(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth, minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 32, 0, 32),
                          child: Text(
                            'headerTitle'.localized(context, 'loginScreen'),
                            maxLines: 3,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (newValue) {
                                  _username = newValue;
                                },
                                focusNode: _usernameNode,
                                decoration: InputDecoration(hintText: 'usernameHint'.localized(context, 'loginScreen')),
                                validator: (value) {
                                  return value!.length > 0 ? null : 'usernameFail'.localized(context, 'loginScreen');
                                },
                              ),
                              TextFormField(
                                onChanged: (newValue) {
                                  _password = newValue;
                                },
                                focusNode: _passwordNode,
                                obscureText: true,
                                decoration: InputDecoration(hintText: 'passwordHint'.localized(context, 'loginScreen')),
                                validator: (value) {
                                  return value!.length > 0 ? null : 'passwordFail'.localized(context, 'loginScreen');
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                            child: SAButton(
                              label: 'accediButton'.localized(context, 'loginScreen'),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _loginDidPress();
                                }
                              },
                              expanded: true,
                              fixedSize: Size.fromHeight(48),
                              borderRadius: 24,
                            )),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('notRegistered'.localized(context, 'loginScreen')),
                              TextButton(
                                onPressed: () {
                                  _registerDidPress();
                                },
                                child: Text(
                                  'registerHere'.localized(context, 'loginScreen'),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('passwordForgot'.localized(context, 'loginScreen')),
                              TextButton(
                                onPressed: () {
                                  _passwordForgotDidPress();
                                },
                                child: Text(
                                  'passwordFogotButton'.localized(context, 'loginScreen'),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
