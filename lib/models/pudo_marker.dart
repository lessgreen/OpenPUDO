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

  PudoMarker({required this.pudoId, this.label, this.lat, this.lon});

  factory PudoMarker.fromJson(Map<String, dynamic> json) => _$PudoMarkerFromJson(json);

  Map<String, dynamic> toJson() => _$PudoMarkerToJson(this);
}

extension PudoUtilities on List<PudoMarker> {
  List<Marker> markers(Function(PudoMarker)? callback, {required Color tintColor}) {
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
