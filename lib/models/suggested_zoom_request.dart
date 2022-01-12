//
//  SuggestedZoomRequest.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'suggested_zoom_request.g.dart';

@JsonSerializable()
class SuggestedZoomRequest {
  final double lat;
  final double lon;

  SuggestedZoomRequest({required this.lat, required this.lon});
  factory SuggestedZoomRequest.fromJson(Map<String, dynamic> json) => _$SuggestedZoomRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SuggestedZoomRequestToJson(this);
}
