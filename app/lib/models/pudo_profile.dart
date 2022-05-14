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
import 'package:qui_green/models/address_model.dart';
import 'package:qui_green/models/pudo_summary.dart';
import 'package:qui_green/models/rating_model.dart';

part 'pudo_profile.g.dart';

@JsonSerializable()
class PudoProfile with PudoCardRepresentation {
  @override
  int pudoId;
  @override
  String businessName;
  @override
  String? pudoPicId;
  @override
  RatingModel? rating;
  @override
  String? customizedAddress;
  @override
  String? get computedAddress {
    return address?.label;
  }

  String? createTms;
  String? publicPhoneNumber;
  String? updateTms;
  AddressModel? address;
  int? customerCount;
  int? packageCount;
  String? savedCO2;
  String? rewardMessage;
  String? imageUrl;

  PudoProfile({
    required this.pudoId,
    required this.businessName,
    this.createTms,
    this.publicPhoneNumber,
    this.updateTms,
    this.address,
    this.customerCount,
    this.packageCount,
    this.savedCO2,
    this.pudoPicId,
    this.rewardMessage,
    this.customizedAddress,
  });

  static PudoProfile get fakeProfile {
    return PudoProfile(
      pudoId: -1,
      businessName: "Bar - La pinta",
      address: AddressModel(
        label: "Via ippolito,8",
        city: "Milano",
        province: "Mi",
        zipCode: "21100",
        street: "Via ippolito",
        streetNum: "8",
      ),
    );
  }

  factory PudoProfile.fromJson(Map<String, dynamic> json) => _$PudoProfileFromJson(json);

  Map<String, dynamic> toJson() => _$PudoProfileToJson(this);
}

extension PudoProfileUtilities on List<PudoProfile> {
  bool containsPudo({required int pudoId}) {
    for (final aRow in this) {
      if (aRow.pudoId == pudoId) {
        return true;
      }
    }
    return false;
  }
}
