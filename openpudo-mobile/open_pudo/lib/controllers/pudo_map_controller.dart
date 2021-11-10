//
//  PudoMapController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/models/address_marker.dart';
import 'package:open_pudo/models/generic_marker.dart';
import 'package:open_pudo/models/pudo_marker.dart';
import 'package:open_pudo/models/pudo_profile.dart';
import 'package:open_pudo/singletons/current_user.dart';
import 'package:open_pudo/singletons/device_manager.dart';
import 'package:open_pudo/singletons/location_manager.dart';
import 'package:open_pudo/singletons/network.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class PudoMapController extends StatefulWidget {
  @override
  _PudoMapControllerState createState() => _PudoMapControllerState();
}

class _PudoMapControllerState extends State<PudoMapController> {
  List<PudoMarker> _pudoMarkerDataSource = [];
  var _lastTriggeredLatitude = 45.4642;
  var _lastTriggeredLongitude = 9.1900;
  var _lastTriggeredZoom = 8;
  var _currentLatitude = 45.4642;
  var _currentLongitude = 9.1900;
  var _currentZoomLevel = 8;
  late MapController _mapController;
  final _textController = TextEditingController();
  var _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    DeviceManager().setContext(context);
    badgeCounter.addListener(() {
      setState(() {});
    });
    _mapController = MapController();
  }

  _refreshLocation() {
    LocationManager().getCurrentLocation().then((value) {
      //try suggested zoom
      _lastTriggeredLatitude = _currentLatitude = value?.latitude ?? 45.4642;
      _lastTriggeredLongitude = _currentLongitude = value?.longitude ?? 9.1900;
      NetworkManager().getSuggestedZoom(lat: _currentLatitude, lon: _currentLongitude).then((response) {
        if (response is int) {
          _currentZoomLevel = response;
        }
        _mapPositionDidChange();
      });
    });
  }

  _showPudoDetails(int pudoId) {
    NetworkManager().getPudoDetails(pudoId: pudoId.toString()).then(
      (response) {
        if (response is PudoProfile) {
          Navigator.of(context).pushNamed('/publicPudoProfile', arguments: {"dataSource": response});
        }
      },
    ).catchError(
      (onError) => SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, 'alert'), onError),
    );
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: true);

    return FocusDetector(
      onFocusGained: () {
        _refreshLocation();
      },
      child: SAScaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
          ),
          title: Text('${packageInfo.appName}'),
          actions: _currentUser.pudoProfile == null && _currentUser.user != null
              ? [
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/myNotifications');
                    },
                    child: Badge(
                      position: BadgePosition(bottom: 10, start: 15),
                      elevation: 0,
                      showBadge: badgeCounter.value > 0,
                      badgeContent: Text('${badgeCounter.value}', style: TextStyle(color: Colors.white, fontSize: 12)),
                      child: Icon(
                        Icons.notifications_none_outlined,
                        color: Colors.white,
                      ),
                    ),
                  )
                ]
              : null,
        ),
        body: Stack(
          children: [
            Container(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  plugins: [
                    MarkerClusterPlugin(),
                  ],
                  maxZoom: 16,
                  minZoom: 8,
                  center: LatLng(_currentLatitude, _currentLongitude),
                  interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  zoom: _currentZoomLevel.toDouble(),
                  onMapCreated: (controller) {
                    _mapPositionDidChange();
                  },
                  onPositionChanged: (mapPosition, boolValue) {
                    _searchFocusNode.unfocus();
                    var mapVisibleMaxDistance = Geolocator.distanceBetween(
                      mapPosition.bounds!.northEast!.latitude,
                      mapPosition.bounds!.northEast!.longitude,
                      mapPosition.bounds!.southWest!.latitude,
                      mapPosition.bounds!.southWest!.longitude,
                    );
                    var visibleChangeDelta = mapVisibleMaxDistance - (mapVisibleMaxDistance * 50 / 100);
                    var distance = Geolocator.distanceBetween(_lastTriggeredLatitude, _lastTriggeredLongitude, mapPosition.center!.latitude, mapPosition.center!.longitude);

                    if (mapPosition.center != null && mapPosition.zoom != null) {
                      _currentLatitude = mapPosition.center!.latitude;
                      _currentLongitude = mapPosition.center!.longitude;
                      _currentZoomLevel = mapPosition.zoom!.toInt();
                    }
                    if (distance > visibleChangeDelta || _lastTriggeredZoom != _currentZoomLevel) {
                      _lastTriggeredLatitude = _currentLatitude;
                      _lastTriggeredLongitude = _currentLongitude;
                      _lastTriggeredZoom = _currentZoomLevel;
                      _mapPositionDidChange();
                    }
                  },
                ),
                layers: [
                  TileLayerOptions(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
                  MarkerClusterLayerOptions(
                    showPolygon: false,
                    maxClusterRadius: 120,
                    size: Size(40, 40),
                    fitBoundsOptions: FitBoundsOptions(
                      padding: EdgeInsets.all(50),
                    ),
                    markers: _pudoMarkerDataSource.markers(
                      (marker) {
                        _showPudoDetails(marker.pudoId);
                      },
                      tintColor: Theme.of(context).primaryColor,
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
            ),
            _buildFloatingSearchBar(),
            Positioned(
              right: 20,
              top: 80,
              child: FloatingActionButton(
                onPressed: () {
                  _refreshLocation();
                },
                child: Image.asset('assets/viewFinder.png', color: Colors.white, width: 32, height: 32),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        floatingActionButton: _currentUser.pudoProfile != null
            ? Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 0, 45),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/updatePackage');
                      },
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              )
            : SizedBox(),
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TypeAheadField(
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          color: Theme.of(context).backgroundColor.withAlpha(230),
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        hideOnEmpty: true,
        hideOnLoading: true,
        itemBuilder: (context, aMarker) {
          if (aMarker is GenericMarker) {
            var label;
            if (aMarker.marker is PudoMarker) {
              PudoMarker pudoMarker = aMarker.marker;
              label = pudoMarker.businessName;
              if (pudoMarker.label != null) {
                label += " - " + pudoMarker.label!;
              }
            } else if (aMarker.marker is AddressMarker) {
              AddressMarker addressMarker = aMarker.marker;
              label = addressMarker.label;
            }
            return ListTile(
              title: Text("$label"),
            );
          } else if (aMarker is String) {
            return ListTile(
              title: Text(aMarker, style: Theme.of(context).textTheme.caption),
            );
          }
          return SizedBox();
        },
        suggestionsCallback: (newValue) {
          if (newValue.isEmpty) {
            return [];
          }
          return NetworkManager().search(lat: _currentLatitude, lon: _currentLongitude, text: newValue).then((value) {
            if (value != null && value is List<GenericMarker>) {
              if (value.isEmpty) {
                return ["Nessun risultato trovato."];
              } else {
                var retArray = [];
                var pudos = [];
                var addresses = [];
                for (var anItem in value) {
                  if (anItem.marker is PudoMarker) {
                    pudos.add(anItem);
                  } else if (anItem.marker is AddressMarker) {
                    addresses.add(anItem);
                  }
                }
                if (pudos.length != 0) {
                  retArray.add("Pudo nelle vicinanze");
                  retArray.addAll(pudos);
                }
                if (addresses.length != 0) {
                  retArray.add("Indirizzi pertinenti");
                  retArray.addAll(addresses);
                }
                return retArray;
              }
            } else {
              return [];
            }
          });
        },
        onSuggestionSelected: (itemSelected) {
          if (itemSelected is GenericMarker) {
            var lat, lon;
            if (itemSelected.marker is PudoMarker) {
              PudoMarker pudoMarker = itemSelected.marker;
              lat = pudoMarker.lat;
              lon = pudoMarker.lon;
            } else if (itemSelected.marker is AddressMarker) {
              AddressMarker addressMarker = itemSelected.marker;
              lat = addressMarker.lat;
              lon = addressMarker.lon;
            }
            _currentLatitude = lat;
            _currentLongitude = lon;
            _mapPositionDidChange();
            _mapController.move(LatLng(_currentLatitude, _currentLongitude), _currentZoomLevel.toDouble());
            if (itemSelected.marker is PudoMarker) {
              _showPudoDetails(itemSelected.marker.pudoId);
            }
          }
          _textController.text = "";
        },
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: _searchFocusNode,
          controller: _textController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(16),
            filled: true,
            fillColor: Theme.of(context).backgroundColor.withAlpha(230),
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).textTheme.caption?.color,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16.0)), borderSide: BorderSide.none),
            hintText: 'searchPlaceholder'.localized(context, "mapScreen"),
          ),
        ),
      ),
    );
  }

  _mapPositionDidChange() {
    NetworkManager().getPudos(lat: _currentLatitude, lon: _currentLongitude, zoom: _currentZoomLevel).then((response) {
      if (response is List<PudoMarker>) {
        if (_pudoMarkerDataSource.length != 0 && response.length == 0) {
          _mapController.move(LatLng(_currentLatitude, _currentLongitude), _currentZoomLevel.toDouble());
          return;
        }
        setState(() {
          _pudoMarkerDataSource = response;
        });
        _mapController.move(LatLng(_currentLatitude, _currentLongitude), _currentZoomLevel.toDouble());
      }
    }).catchError(
      (onError) => SAAlertDialog.displayAlertWithClose(
        context,
        "genericTitle".localized(context, "alert"),
        onError,
      ),
    );
  }
}
