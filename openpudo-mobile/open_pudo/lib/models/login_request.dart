//
//  LoginRequest.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  final String login;
  final String password;

  LoginRequest({required this.login, required this.password});
  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
