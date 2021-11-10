//
//  GenericMarker.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 25/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';
import 'package:open_pudo/models/pudo_marker.dart';

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
      retValue.marker = PudoMarker.fromJson(retValue.marker);
    } else if (retValue.type.toLowerCase() == "address") {
      retValue.marker = AddressMarker.fromJson(retValue.marker);
    }
    return retValue;
  }
}
