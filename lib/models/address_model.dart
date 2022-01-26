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
  final int? addressId;
  final String? city;
  final String? country;
  final String? createTms;
  final String? label;
  final double? lat;
  final double? lon;
  final String? province;
  final String? street;
  final String? streetNum;
  final String? updateTms;
  final String? zipCode;

  AddressModel({
    this.addressId,
    this.city,
    this.country,
    this.createTms,
    this.label,
    this.lat,
    this.lon,
    this.province,
    this.street,
    this.streetNum,
    this.updateTms,
    this.zipCode,
  });
  factory AddressModel.fromJson(Map<String, dynamic> json) => _$AddressModelFromJson(json);
  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}
