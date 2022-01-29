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
import 'package:qui_green/models/address_model.dart';
import 'package:qui_green/models/pudo_model.dart';

part 'geo_marker.g.dart';

@JsonSerializable()
class GeoMarker {
  final PudoModel? pudo;
  final AddressModel? address;
  final double? lat;
  final double? lon;
  final String? signature;
  final double? distanceFromOrigin;

  GeoMarker({required this.pudo, this.address, this.lat, this.lon, this.signature, this.distanceFromOrigin});

  factory GeoMarker.fromJson(Map<String, dynamic> json) => _$GeoMarkerFromJson(json);

  Map<String, dynamic> toJson() => _$GeoMarkerToJson(this);
}

extension PudoUtilities on List<GeoMarker> {
  List<AddressModel>? get addresses {
    List<AddressModel> retArray = [];
    for (final aRow in this) {
      if (aRow.address != null) {
        retArray.add(aRow.address!);
      }
    }
    return retArray.isNotEmpty ? retArray : null;
  }

  List<PudoModel>? get pudos {
    List<PudoModel> retArray = [];
    for (final aRow in this) {
      if (aRow.pudo != null) {
        retArray.add(aRow.pudo!);
      }
    }
    return retArray.isNotEmpty ? retArray : null;
  }

  List<Marker> markers(Function(GeoMarker)? callback, {required Color tintColor}) {
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
