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

class UserPositionController extends StatefulWidget {
  const UserPositionController({Key? key}) : super(key: key);

  @override
  _UserPositionControllerState createState() => _UserPositionControllerState();
}

class _UserPositionControllerState extends State<UserPositionController> {
  Future<LocationData?> _tryGetUserLocation() async {
    Location location = new Location();

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
        body: Stack(
          children: [
            PositionedDirectional(
              start: 0,
              end: 0,
              top: 200,
              child: SvgPicture.asset('assets/userPositionArt.svg', semanticsLabel: 'Art Background'),
            ),
            PositionedDirectional(
              start: 20,
              end: 20,
              bottom: 116,
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
                child: const Text('Ok, grazie!'),
                onPressed: () {
                  _tryGetUserLocation().then((value) {
                    print("acquired position: $value");
                  });
                },
              ),
            ),
            PositionedDirectional(
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
                child: const Text('Inserisci indirizzo'),
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
                      'Vediamo dove ti trovi',
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
                          'Per poterti fornire informazioni rilevanti\nabbiamo bisogno di accedere alla tua posizione.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
