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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/view_models/home_onboarding/home_maps_controller_viewmodel.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class HomeMapsController extends StatefulWidget {
  const HomeMapsController({Key? key, required this.initialPosition}) : super(key: key);
  final LatLng initialPosition;

  @override
  _HomeMapsControllerState createState() => _HomeMapsControllerState();
}

class _HomeMapsControllerState extends State<HomeMapsController> {
  void _showErrorDialog(BuildContext context, String val) => SAAlertDialog.displayAlertWithClose(context, "Error", val);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeMapsControllerViewModel(),
      child: Consumer<HomeMapsControllerViewModel?>(builder: (_, viewModel, __) {
        viewModel?.showErrorDialog = (String val) => _showErrorDialog(context, val);
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
              padding: const EdgeInsetsDirectional.all(0),
              brightness: Brightness.dark,
              backgroundColor: AppColors.primaryColorDark,
              middle: Text(
                'Seleziona un pudo',
                style: Theme.of(context).textTheme.navBarTitle,
              ),
              leading: CupertinoNavigationBarBackButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              )),
          child: SAScaffold(
            isLoading: NetworkManager.instance.networkActivity,
            body: Stack(children: [
              FlutterMap(
                  mapController: viewModel!.mapController,
                  options: MapOptions(
                    center: widget.initialPosition,
                    onMapCreated: (controller) {
                      viewModel.onMapCreate(controller, widget.initialPosition);
                      viewModel.loadPudos(requireZoomLevelRefresh: true);
                    },
                    interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
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
                    zoom: viewModel.currentZoomLevel.toDouble(),
                    plugins: [
                      MarkerClusterPlugin(),
                    ],
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      retinaMode: true,
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
                            viewModel.onPudoClick(context, marker, widget.initialPosition);
                          },
                          tintColor: AppColors.primaryColorDark,
                        ),
                        builder: (context, markers) {
                          return FloatingActionButton(
                            child: Text(markers.length.toString(), style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white)),
                            onPressed: null,
                          );
                        }),
                  ]),
            ]),
          ),
        );
      }),
    );
  }
}
