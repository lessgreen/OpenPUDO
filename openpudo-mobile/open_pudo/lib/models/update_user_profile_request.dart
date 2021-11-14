//
//  UpdateUserProfileRequest.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'update_user_profile_request.g.dart';

@JsonSerializable()
class UpdateUserProfileRequest {
  final String firstName;
  final String lastName;
  final String? ssn;

  UpdateUserProfileRequest({required this.firstName, required this.lastName, this.ssn});
  factory UpdateUserProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateUserProfileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserProfileRequestToJson(this);
}
