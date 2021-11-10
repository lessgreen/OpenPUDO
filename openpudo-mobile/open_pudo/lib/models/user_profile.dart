//
//  UserProfile.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  String firstName;
  String lastName;
  String? ssn;
  String? createTms;
  String? profilePicId;
  final int? userId;
  bool? pudoOwner;

  UserProfile({required this.firstName, required this.lastName, this.ssn, this.createTms, this.profilePicId, this.userId, this.pudoOwner});
  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
