//
//  MapSearchAddressesRequest.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'map_search_addresses_request.g.dart';

@JsonSerializable()
class MapSearchAddressesRequest {
  final double? lat;
  final double? lon;
  final String text;

  MapSearchAddressesRequest({required this.text, this.lat, this.lon});
  factory MapSearchAddressesRequest.fromJson(Map<String, dynamic> json) => _$MapSearchAddressesRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MapSearchAddressesRequestToJson(this);
}
