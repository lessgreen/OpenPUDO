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

// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/widgets/text_field_button.dart';
import 'package:qui_green/view_models/maps_controller_viewmodel.dart';
import 'package:qui_green/widgets/pudo_map_card.dart';
import 'package:qui_green/models/pudo_marker.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class MapsController extends StatefulWidget {
  const MapsController({Key? key, required this.initialPosition}) : super(key: key);
  final LatLng initialPosition;

  @override
  _MapsControllerState createState() => _MapsControllerState();
}

class _MapsControllerState extends State<MapsController> {
  void _showErrorDialog(BuildContext context, String val) => SAAlertDialog.displayAlertWithClose(context, "Error", val);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProxyProvider0<MapsControllerViewModel?>(create: (context) => MapsControllerViewModel(), update: (context, viewModel) => viewModel),
        ],
        child: Consumer<MapsControllerViewModel?>(builder: (_, viewModel, __) {
          viewModel?.showErrorDialog = (String val) => _showErrorDialog(context, val);
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
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
                    mapController: viewModel!.mapController,
                    options: MapOptions(
                      center: widget.initialPosition,
                      onMapCreated: (controller) {
                        viewModel.mapController = controller;
                        viewModel.loadPudos();
                      },
                      onPositionChanged: (mapPosition, boolValue) {
                        var mapVisibleMaxDistance = Geolocator.distanceBetween(
                          mapPosition.bounds!.northEast!.latitude,
                          mapPosition.bounds!.northEast!.longitude,
                          mapPosition.bounds!.southWest!.latitude,
                          mapPosition.bounds!.southWest!.longitude,
                        );
                        var visibleChangeDelta = mapVisibleMaxDistance - (mapVisibleMaxDistance * 50 / 100);
                        var distance = Geolocator.distanceBetween(viewModel.lastTriggeredLatitude, viewModel.lastTriggeredLongitude, mapPosition.center!.latitude, mapPosition.center!.longitude);

                        if (mapPosition.center != null && mapPosition.zoom != null) {
                          viewModel.updateCurrentMapPosition(mapPosition);
                        }
                        if (distance > visibleChangeDelta || viewModel.lastTriggeredZoom != viewModel.currentZoomLevel) {
                          viewModel.updateLastMapPosition(mapPosition);
                          viewModel.loadPudos();
                        }
                      },
                      maxZoom: 16,
                      minZoom: 8,
                      plugins: [
                        MarkerClusterPlugin(),
                      ],
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerClusterLayerOptions(
                        showPolygon: false,
                        maxClusterRadius: 120,
                        size: const Size(40, 40),
                        fitBoundsOptions: const FitBoundsOptions(
                          padding: EdgeInsets.all(50),
                        ),
                        markers: viewModel.pudos.markers(
                          (marker) {
                            viewModel.selectPudo(context, marker.pudoId);
                          },
                          tintColor: AppColors.primaryColorDark,
                        ),
                        builder: (context, markers) {
                          return FloatingActionButton(
                            child: Text(markers.length.toString(), style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white)),
                            onPressed: null,
                          );
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
                          padding: const EdgeInsets.only(bottom: Dimension.padding),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextFieldButton(
                                  text: "Salta",
                                  onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.personalData),
                                ),
                              ),
                              Text(
                                "Ecco i punti di ritiro vicino a te",
                                style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        AnimatedCrossFade(
                          secondChild: Padding(
                              padding: const EdgeInsets.only(left: Dimension.paddingXS, right: Dimension.paddingXS, bottom: Dimension.paddingM),
                              child: PudoMapCard(
                                  name: viewModel.pudoProfile?.businessName ?? "",
                                  address: viewModel.pudoProfile?.address?.label ?? "",
                                  stars: viewModel.pudoProfile?.ratingModel?.averageScore ?? 0,
                                  onTap: () {
                                    viewModel.onPudoClick(context, viewModel.pudoProfile!, widget.initialPosition);
                                  },
                                  image: viewModel.pudoProfile?.pudoPicId ?? 'https://cdn.skuola.net/news_foto/2017/descrizione-bar.jpg')),
                          crossFadeState: viewModel.pudoProfile == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 100),
                          firstChild: SizedBox(width: MediaQuery.of(context).size.width),
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
