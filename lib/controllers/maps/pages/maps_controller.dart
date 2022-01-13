//
//   user_position_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Wed Jan 05 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/controllers/maps/di/maps_controller_providers.dart';
import 'package:qui_green/controllers/maps/viewmodel/maps_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';

class MapsController extends StatefulWidget {
  const MapsController({Key? key}) : super(key: key);

  @override
  _MapsControllerState createState() => _MapsControllerState();
}

class _MapsControllerState extends State<MapsController> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: mapsControllerProviders,
        child: Consumer<MapsControllerViewModel?>(builder: (_, viewModel, __) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                leading: const SizedBox(),
              ),
              body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/maps.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      decoration:
                          BoxDecoration(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}
