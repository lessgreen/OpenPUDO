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

part 'address_model.g.dart';

@JsonSerializable()
class AddressModel {
  @JsonKey(includeIfNull: false)
  final int? pudoId;
  @JsonKey(includeIfNull: false)
  final String? city;
  @JsonKey(includeIfNull: false)
  final String? country;
  @JsonKey(includeIfNull: false)
  final String? label;
  @JsonKey(includeIfNull: false)
  final double? lat;
  @JsonKey(includeIfNull: false)
  final double? lon;
  @JsonKey(includeIfNull: false)
  final String? province;
  @JsonKey(includeIfNull: false)
  final String? street;
  @JsonKey(includeIfNull: false)
  final String? streetNum;
  @JsonKey(includeIfNull: false)
  final String? zipCode;

  AddressModel({
    this.pudoId,
    this.city,
    this.country,
    this.label,
    this.lat,
    this.lon,
    this.province,
    this.street,
    this.streetNum,
    this.zipCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}
