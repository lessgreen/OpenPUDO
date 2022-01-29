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
  final PudoMarkerData pudo;
  final double? lat;
  final double? lon;
  final double? distanceFromOrigin;

  PudoMarker({required this.pudo, this.lat, this.lon,this.distanceFromOrigin});

  factory PudoMarker.fromJson(Map<String, dynamic> json) => _$PudoMarkerFromJson(json);

  Map<String, dynamic> toJson() => _$PudoMarkerToJson(this);
}

@JsonSerializable()
class PudoMarkerData{
  final int pudoId;
  final String? businessName;
  final String? pudoPicId;
  final String? label;
  final PudoMarkerRating? rating;

  PudoMarkerData(
      {required this.pudoId, this.businessName, this.pudoPicId, this.label, this.rating});
  factory PudoMarkerData.fromJson(Map<String, dynamic> json) => _$PudoMarkerDataFromJson(json);

  Map<String, dynamic> toJson() => _$PudoMarkerDataToJson(this);
}

@JsonSerializable()
class PudoMarkerRating{
  final int pudoId;
  final int? reviewCount;
  final int? averageScore;

  PudoMarkerRating({required this.pudoId, this.reviewCount, this.averageScore});
  factory PudoMarkerRating.fromJson(Map<String, dynamic> json) => _$PudoMarkerRatingFromJson(json);

  Map<String, dynamic> toJson() => _$PudoMarkerRatingToJson(this);
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
