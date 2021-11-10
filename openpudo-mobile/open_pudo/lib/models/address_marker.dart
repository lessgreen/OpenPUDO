//
//  AddressMarker.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 25/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'address_marker.g.dart';

@JsonSerializable()
class AddressMarker {
  final String label;
  final double lat;
  final double lon;
  final String precision;
  final String resultId;

  AddressMarker({required this.label, required this.lat, required this.lon, required this.precision, required this.resultId});
  factory AddressMarker.fromJson(Map<String, dynamic> json) => _$AddressMarkerFromJson(json);
  Map<String, dynamic> toJson() => _$AddressMarkerToJson(this);
}
