//
//   user_position_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Wed Jan 05 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

class UserPositionController extends StatefulWidget {
  const UserPositionController({Key? key}) : super(key: key);

  @override
  _UserPositionControllerState createState() => _UserPositionControllerState();
}

class _UserPositionControllerState extends State<UserPositionController> {
  Future<LocationData?> _tryGetUserLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: const SizedBox(),
        ),
        body: Column(
          children: [
            Center(
              child: Text(
                'Vediamo dove ti trovi',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Center(
                child: Text(
                  'Per poterti fornire informazioni rilevanti\nabbiamo bisogno di accedere alla tua posizione.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
            const SizedBox(
              height: Dimension.paddingL,
            ),
            SvgPicture.asset(ImageSrc.userPositionArt,
                semanticsLabel: 'Art Background'),
            const Spacer(),
            MainButton(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimension.padding),
              onPressed: () {
                _tryGetUserLocation().then((value) {
                  //print("acquired position: $value");
                });
              },
              text: 'Ok, grazie!',
            ),
            const SizedBox(height: Dimension.padding),
            MainButton(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimension.padding,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(Routes.confirmPhone);
              },
              text: 'Inserisci indirizzo',
            ),
            const SizedBox(height: Dimension.paddingL)
          ],
        ),
      ),
    );
  }
}
