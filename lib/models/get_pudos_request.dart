//
//  GetPudosRequest.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'get_pudos_request.g.dart';

@JsonSerializable()
class GetPudosRequest {
  final double lat;
  final double lon;
  final int zoom;

  GetPudosRequest({required this.lat, required this.lon, required this.zoom});
  factory GetPudosRequest.fromJson(Map<String, dynamic> json) => _$GetPudosRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GetPudosRequestToJson(this);
}
