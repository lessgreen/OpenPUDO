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
import 'package:qui_green/models/reward_option.dart';

part 'registration_pudo_request.g.dart';

@JsonSerializable()
class RegistrationPudoRequest {
  final PudoRequest? pudo;
  final PudoAddressMarker? addressMarker;
  final List<RewardOption>? rewardPolicy;
  final String? dynamicLinkId;

  RegistrationPudoRequest({required this.pudo, this.addressMarker, this.rewardPolicy, this.dynamicLinkId});

  factory RegistrationPudoRequest.fromJson(Map<String, dynamic> json) => _$RegistrationPudoRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationPudoRequestToJson(this);
}

@JsonSerializable()
class PudoRequest {
  final String businessName;
  final String publicPhoneNumber;
  final String? email;

  PudoRequest({required this.businessName, required this.publicPhoneNumber, this.email});

  factory PudoRequest.fromJson(Map<String, dynamic> json) => _$PudoRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PudoRequestToJson(this);
}

@JsonSerializable()
class PudoAddressMarker {
  final String signature;
  final AddressModel address;

  PudoAddressMarker({required this.signature, required this.address});

  factory PudoAddressMarker.fromJson(Map<String, dynamic> json) => _$PudoAddressMarkerFromJson(json);

  Map<String, dynamic> toJson() => _$PudoAddressMarkerToJson(this);
}
