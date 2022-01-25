//
//  PudoProfile.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 25/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';
import 'package:qui_green/models/address_model.dart';
import 'package:qui_green/models/rating_model.dart';

part 'pudo_profile.g.dart';

@JsonSerializable()
class PudoProfile {
  String businessName;
  String? contactNotes;
  String? createTms;
  String? publicPhoneNumber;
  String? pudoPicId;
  int? pudoId;
  String? updateTms;
  String? vat;
  AddressModel? address;
  RatingModel? ratingModel;
  int? customerCount;
  int? packageCount;
  String? rewardMessage;
  String? customizedAddress;
  String? imageUrl;

  PudoProfile({
    required this.businessName,
    this.contactNotes,
    this.createTms,
    this.publicPhoneNumber,
    this.pudoId,
    this.updateTms,
    this.vat,
    this.address,
    this.customerCount,
    this.pudoPicId,
    this.rewardMessage,
    this.customizedAddress,
  });

  factory PudoProfile.fromJson(Map<String, dynamic> json) =>
      _$PudoProfileFromJson(json);

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
