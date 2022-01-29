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

import 'package:json_annotation/json_annotation.dart';
import 'package:qui_green/models/geo_marker.dart';

import 'address_marker.dart';

part 'generic_marker.g.dart';

@JsonSerializable()
class GenericMarker {
  dynamic marker;
  final String type;
  final String? executionId;
  final String? message;
  final int? returnCode;

  GenericMarker({required this.marker, required this.type, this.executionId, this.message, this.returnCode});
  factory GenericMarker.fromJson(Map<String, dynamic> json) => _$GenericMarkerFromJson(json);
  Map<String, dynamic> toJson() => _$GenericMarkerToJson(this);

  static GenericMarker fromGenericJson(Map<String, dynamic> json) {
    var retValue = GenericMarker.fromJson(json);
    if (retValue.type.toLowerCase() == "pudo") {
      retValue.marker = GeoMarker.fromJson(retValue.marker);
    } else if (retValue.type.toLowerCase() == "address") {
      retValue.marker = AddressMarker.fromJson(retValue.marker);
    }
    return retValue;
  }
}
