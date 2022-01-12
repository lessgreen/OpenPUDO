//
//  BaseResponse.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

@JsonSerializable()
class OPBaseResponse {
  final String? executionId;
  final int returnCode;
  final String? message;
  final dynamic payload;

  OPBaseResponse({this.executionId, required this.returnCode, this.message, this.payload});
  factory OPBaseResponse.fromJson(Map<String, dynamic> json) => _$OPBaseResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OPBaseResponseToJson(this);
}
