//
//  UpdatePudoRequest.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'update_pudo_request.g.dart';

@JsonSerializable()
class UpdatePudoRequest {
  final String businessName;
  final String? contactNotes;
  final String? phoneNumber;
  final String? vat;

  UpdatePudoRequest({required this.businessName, this.contactNotes, this.phoneNumber, this.vat});
  factory UpdatePudoRequest.fromJson(Map<String, dynamic> json) => _$UpdatePudoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePudoRequestToJson(this);
}
