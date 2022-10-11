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

part 'access_token_data.g.dart';

enum AccessProfileType {
  @JsonValue("guest")
  guest,
  @JsonValue("pudo")
  pudo,
  @JsonValue("customer")
  customer
}

@JsonSerializable()
class AccessTokenData {
  final String accessToken;
  final String expireDate;
  final String issueDate;
  final AccessProfileType accessProfile;
  AccessTokenData({required this.accessToken, required this.expireDate, required this.issueDate, required this.accessProfile});
  factory AccessTokenData.fromJson(Map<String, dynamic> json) => _$AccessTokenDataFromJson(json);
  Map<String, dynamic> toJson() => _$AccessTokenDataToJson(this);
}
