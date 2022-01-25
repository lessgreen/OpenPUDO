//
//  PudoMarker.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 25/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter_map/plugin_api.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

part 'pudo_marker.g.dart';

@JsonSerializable()
class PudoMarker {
  final int pudoId;
  final String? label;
  final double? lat;
  final double? lon;

  PudoMarker(
      {
      required this.pudoId,
      this.label,
      this.lat,
      this.lon});

  factory PudoMarker.fromJson(Map<String, dynamic> json) =>
      _$PudoMarkerFromJson(json);

  Map<String, dynamic> toJson() => _$PudoMarkerToJson(this);
}

extension PudoUtilities on List<PudoMarker> {
  List<Marker> markers(Function(PudoMarker)? callback,
      {required Color tintColor}) {
    List<Marker> retArray = [];

    for (final aRow in this) {
      if (aRow.lat != null && aRow.lon != null) {
        retArray.add(
          Marker(
            width: 33.0,
            height: 33.0,
            point: LatLng(aRow.lat!, aRow.lon!),
            builder: (ctx) => GestureDetector(
              onTap: () {
                callback?.call(aRow);
              },
              child: ImageIcon(
                const AssetImage('assets/pudoMarker.png'),
                color: tintColor,
              ),
            ),
          ),
        );
      }
    }

    return retArray;
  }
}
