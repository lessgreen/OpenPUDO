//
//  AddressModel.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 25/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

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
