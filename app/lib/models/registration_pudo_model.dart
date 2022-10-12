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
import 'dart:io';

import 'package:qui_green/models/registration_pudo_request.dart';
import 'package:qui_green/models/reward_option.dart';

class RegistrationPudoModel {
  final String? businessName;
  final PudoAddressMarker? addressMarker;
  final String? publicPhoneNumber;
  final String? email;
  final File? profilePic;
  final List<RewardOption>? rewardPolicy;
  final String? dynamicLinkId;

  RegistrationPudoModel({this.businessName, this.publicPhoneNumber, this.email, this.profilePic, this.addressMarker, this.rewardPolicy, this.dynamicLinkId});

  RegistrationPudoModel copyWith(
          {String? businessName, String? publicPhoneNumber, String? email, File? profilePic, PudoAddressMarker? addressMarker, List<RewardOption>? rewardPolicy, String? dynamicLinkId}) =>
      RegistrationPudoModel(
          businessName: businessName ?? this.businessName,
          publicPhoneNumber: publicPhoneNumber ?? this.publicPhoneNumber,
          email: email ?? this.email,
          profilePic: profilePic ?? this.profilePic,
          addressMarker: addressMarker ?? this.addressMarker,
          rewardPolicy: rewardPolicy ?? this.rewardPolicy,
          dynamicLinkId: dynamicLinkId ?? this.dynamicLinkId);

  RegistrationPudoRequest toRequest() => RegistrationPudoRequest(
      pudo: PudoRequest(publicPhoneNumber: publicPhoneNumber!, businessName: businessName!, email: email), addressMarker: addressMarker, rewardPolicy: rewardPolicy, dynamicLinkId: dynamicLinkId);
}
