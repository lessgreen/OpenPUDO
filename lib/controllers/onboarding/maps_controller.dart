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
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/view_models/maps_controller_viewmodel.dart';
import 'package:qui_green/widgets/adress_field_pudo_search.dart';
import 'package:qui_green/widgets/pudo_map_card.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/widgets/text_field_button.dart';

class MapsController extends StatefulWidget {
  const MapsController(
      {Key? key,
      this.initialPosition,
      required this.getUserPosition,
      required this.enableAddressSearch,
      required this.enablePudoCards,
      required this.useCupertinoScaffold,
      required this.title,
      required this.canGoBack,
      this.canOpenProfilePage = false})
      : super(key: key);
  final LatLng? initialPosition;
  final bool getUserPosition;
  final bool enableAddressSearch;
  final bool enablePudoCards;
  final bool useCupertinoScaffold;
  final bool canOpenProfilePage;
  final String title;
  final bool canGoBack;

  @override
  _MapsControllerState createState() => _MapsControllerState();
}

class _MapsControllerState extends State<MapsController> with ConnectionAware, TickerProviderStateMixin {
  void _showErrorDialog(BuildContext context, String val) => SAAlertDialog.displayAlertWithClose(context, "Error", val);

  void animateMapTo(MapsControllerViewModel viewModel, LatLng pos) {
    final _latTween = Tween<double>(
      begin: viewModel.mapController?.center.latitude,
      end: pos.latitude,
    );
    final _lngTween = Tween<double>(
      begin: viewModel.mapController?.center.longitude,
      end: pos.longitude,
    );
    final _zoomTween = Tween<double>(begin: viewModel.mapController?.zoom, end: 16);

    var controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      viewModel.mapController?.move(
        LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
        _zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Widget _buildPageWithCupertinoScaffold(MapsControllerViewModel viewModel) => CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.all(0),
        brightness: Brightness.dark,
        backgroundColor: AppColors.primaryColorDark,
        leading: widget.canGoBack
            ? CupertinoNavigationBarBackButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        middle: Text(
          widget.title,
          style: Theme.of(context).textTheme.navBarTitle,
        ),
        trailing: widget.canOpenProfilePage
            ? InkWell(
                onTap: () => Navigator.of(context).pushNamed(Routes.profile),
                child: Container(margin: const EdgeInsets.only(right: Dimension.paddingS), width: 40, child: SvgPicture.asset(ImageSrc.profileArt, color: Colors.white)),
              )
            : null,
      ),
      child: SafeArea(
        child: Stack(
          children: [_buildMap(viewModel), _buildBody(viewModel)],
        ),
      ));

  Widget _buildPageWithCustomSpecificScaffold(MapsControllerViewModel viewModel) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.8),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          toolbarHeight: 0,
          leading: const SizedBox(),
        ),
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            _buildMap(viewModel),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (widget.canGoBack)
                                CupertinoNavigationBarBackButton(
                                  color: AppColors.primaryColorDark,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              if (!widget.canGoBack) const SizedBox(),
                              TextFieldButton(
                                text: "Salta",
                                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                                  Routes.personalData,
                                  ModalRoute.withName('/'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.navBarTitleDark,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildBody(viewModel))
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildBody(MapsControllerViewModel viewModel) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [if (widget.enableAddressSearch) _buildSearch(viewModel), const Spacer(), if (widget.enablePudoCards) _buildCards(viewModel)],
      );

  Widget _buildSearch(MapsControllerViewModel viewModel) => Padding(
        padding: const EdgeInsets.all(Dimension.padding),
        child: AdressFieldPudoSearch(
          viewModel: viewModel,
        ),
      );

  Widget _buildCards(MapsControllerViewModel viewModel) => AnimatedCrossFade(
      duration: const Duration(milliseconds: 100),
      crossFadeState: viewModel.pudos.isEmpty || viewModel.currentZoomLevel < 14 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 0,
      ),
      secondChild: SizedBox(
        height: 100 + (Dimension.paddingM * 2),
        child: PageView.builder(
          itemCount: viewModel.pudos.length,
          controller: viewModel.pageController,
          onPageChanged: (value) async {
            //Check if is fetching something (image not included)
            if (!viewModel.isReloadingPudos) {
              animateMapTo(viewModel, LatLng(viewModel.pudos[value].lat ?? 0, viewModel.pudos[value].lon ?? 0));
              viewModel.showingCardPudo = viewModel.pudos[value].pudo!.pudoId;
            }
          },
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(
              top: Dimension.paddingM,
              left: Dimension.paddingXS,
              right: Dimension.paddingXS,
              bottom: Dimension.paddingM,
            ),
            child: PudoMapCard(
                name: viewModel.pudos[index].pudo?.businessName ?? "",
                address: viewModel.pudos[index].pudo?.label ?? "",
                stars: viewModel.pudos[index].pudo?.rating?.reviewCount ?? 0,
                hasShadow: true,
                onTap: () {
                  viewModel.onPudoClick(context, viewModel.pudos[index]);
                },
                image: viewModel.pudos[index].pudo?.pudoPicId),
          ),
        ),
      ));

  Widget _buildMap(MapsControllerViewModel viewModel) => SAScaffold(
        isLoading: NetworkManager.instance.networkActivity,
        body: FlutterMap(
          mapController: viewModel.mapController,
          options: MapOptions(
            center: widget.initialPosition,
            onMapCreated: (controller) {
              viewModel.onMapCreate(controller, widget.initialPosition, widget.getUserPosition);
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
              var distance = Geolocator.distanceBetween(
                viewModel.lastTriggeredLatitude,
                viewModel.lastTriggeredLongitude,
                mapPosition.center!.latitude,
                mapPosition.center!.longitude,
              );

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
              size: const Size(40, 40),
              fitBoundsOptions: const FitBoundsOptions(
                padding: EdgeInsets.all(50),
              ),
              maxClusterRadius: 120,
              markers: viewModel.pudos.markers(
                (marker) {
                  viewModel.selectPudo(context, marker, widget.enablePudoCards);
                },
                selectedMarker: widget.enablePudoCards ? viewModel.showingCardPudo : null,
                tintColor: AppColors.primaryColorDark,
              ),
              builder: (context, markers) {
                return FloatingActionButton(
                  heroTag: Key(markers.length.toString() + markers.first.point.toSexagesimal()),
                  child: Text(
                    markers.length.toString(),
                    style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white),
                  ),
                  onPressed: null,
                );
              },
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MapsControllerViewModel(),
      child: Consumer<MapsControllerViewModel?>(
        builder: (_, viewModel, __) {
          viewModel?.animateMapTo = animateMapTo;
          viewModel?.showErrorDialog = (String val) => _showErrorDialog(context, val);
          return WillPopScope(onWillPop: () async => false, child: widget.useCupertinoScaffold ? _buildPageWithCupertinoScaffold(viewModel!) : _buildPageWithCustomSpecificScaffold(viewModel!));
        },
      ),
    );
  }
}
