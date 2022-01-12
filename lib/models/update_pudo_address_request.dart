//
//  UpdatePudoAddressRequest.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'update_pudo_address_request.g.dart';

@JsonSerializable()
class UpdatePudoAddressRequest {
  final String label;
  final String resultId;

  UpdatePudoAddressRequest({required this.label, required this.resultId});
  factory UpdatePudoAddressRequest.fromJson(Map<String, dynamic> json) => _$UpdatePudoAddressRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePudoAddressRequestToJson(this);
}
