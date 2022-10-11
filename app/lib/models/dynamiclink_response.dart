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
import 'package:qui_green/models/access_token_data.dart';
import 'package:qui_green/models/geo_marker.dart';

part 'dynamiclink_response.g.dart';

enum DynamicLinkRoute {
  @JsonValue("enroll-prospect")
  enrollProspect
}

@JsonSerializable()
class DynamicLinkResponse {
  DynamicLinkRoute route;
  DynamicLinkData data;

  DynamicLinkResponse({
    required this.route,
    required this.data,
  });

  factory DynamicLinkResponse.fromJson(Map<String, dynamic> json) => _$DynamicLinkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DynamicLinkResponseToJson(this);
}

@JsonSerializable()
class DynamicLinkData {
  AccessTokenData? accessTokenData;
  String? phoneNumber;
  String? accountType;
  String? firstName;
  String? lastName;
  String? businessName;
  int? favouritePudoId;
  GeoMarker? address;

  DynamicLinkData({
    this.accessTokenData,
    this.phoneNumber,
    this.accountType,
    this.firstName,
    this.lastName,
    this.businessName,
    this.favouritePudoId,
  });

  factory DynamicLinkData.fromJson(Map<String, dynamic> json) => _$DynamicLinkDataFromJson(json);

  Map<String, dynamic> toJson() => _$DynamicLinkDataToJson(this);
}
