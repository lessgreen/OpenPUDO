//
//  PudoProfile.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 25/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';
import 'package:open_pudo/models/address_model.dart';

part 'pudo_profile.g.dart';

@JsonSerializable()
class PudoProfile {
  String businessName;
  String? contactNotes;
  String? createTms;
  String? phoneNumber;
  String? profilePicId;
  int? pudoId;
  String? updateTms;
  String? vat;
  AddressModel? address;

  PudoProfile({
    required this.businessName,
    this.contactNotes,
    this.createTms,
    this.phoneNumber,
    this.pudoId,
    this.updateTms,
    this.vat,
    this.address,
  });
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
