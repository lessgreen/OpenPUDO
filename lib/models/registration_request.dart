//
//  RegistrationRequest.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/user_profile.dart';

part 'registration_request.g.dart';

@JsonSerializable()
class RegistrationRequest {
  final String? email;
  final String password;
  final String? phoneNumber;
  final String? username;
  final UserProfile user;
  final PudoProfile? pudo;

  RegistrationRequest({this.email, required this.password, this.phoneNumber, this.username, required this.user, this.pudo});
  factory RegistrationRequest.fromJson(Map<String, dynamic> json) => _$RegistrationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegistrationRequestToJson(this);
}
