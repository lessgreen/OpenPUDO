//
//  MapSearchRequest.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'map_search_request.g.dart';

@JsonSerializable()
class MapSearchRequest {
  final double? lat;
  final double? lon;
  final String text;

  MapSearchRequest({required this.text, this.lat, this.lon});
  factory MapSearchRequest.fromJson(Map<String, dynamic> json) => _$MapSearchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MapSearchRequestToJson(this);
}
