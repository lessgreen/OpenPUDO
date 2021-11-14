//
//  AccessTokenData.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'access_token_data.g.dart';

@JsonSerializable()
class AccessTokenData {
  final String accessToken;
  final String expireDate;
  final String issueDate;

  AccessTokenData({required this.accessToken, required this.expireDate, required this.issueDate});
  factory AccessTokenData.fromJson(Map<String, dynamic> json) => _$AccessTokenDataFromJson(json);
  Map<String, dynamic> toJson() => _$AccessTokenDataToJson(this);
}
