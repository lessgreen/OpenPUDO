//
//  login_controller.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

class LoginController extends StatefulWidget {
  const LoginController({Key? key}) : super(key: key);

  @override
  _LoginControllerState createState() => _LoginControllerState();
}

class _LoginControllerState extends State<LoginController> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: const SizedBox(),
        ),
        body: Stack(
          children: [
            Center(
              child: SvgPicture.asset(ImageSrc.insertPhoneArt,
                  semanticsLabel: 'Art Background'),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Non sei ancora un utente?',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Cosa aspetti?',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ],
                  ),
                ),
                const Spacer()
              ],
            ),
            PositionedDirectional(
              start: 20,
              end: 20,
              bottom: 50,
              child: TextButton(
                child: const Text('Accedi con il tuo numero di telefono'),
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(Routes.insertPhone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
