//
//   user_position_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Wed Jan 05 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/widgets/text_field_button.dart';
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
                backgroundColor: Colors.white.withOpacity(0.8),
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                centerTitle: true,
                toolbarHeight: 0,
                leading: const SizedBox(),
              ),
              body: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      center: LatLng(46, 12),
                      zoom: 13.0,
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                        attributionBuilder: (_) {
                          return const Text("© OpenStreetMap");
                        },
                      ),
                    ],
                  ),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          color: Colors.white.withOpacity(0.8),
                          padding:
                              const EdgeInsets.only(bottom: Dimension.padding),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextFieldButton(
                                  text: "Salta",
                                  onPressed: () => print("jump"),
                                ),
                              ),
                              Text(
                                "Ecco i punti di ritiro vicino a te",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }));
  }
}
