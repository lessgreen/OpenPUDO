// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      ssn: json['ssn'] as String?,
      createTms: json['createTms'] as String?,
      profilePicId: json['profilePicId'] as String?,
      userId: json['userId'] as int?,
      pudoOwner: json['pudoOwner'] as bool?,
      packageCount: json['packageCount'] as int?,
      savedCO2: json['savedCO2'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'ssn': instance.ssn,
      'createTms': instance.createTms,
      'profilePicId': instance.profilePicId,
      'userId': instance.userId,
      'pudoOwner': instance.pudoOwner,
      'packageCount': instance.packageCount,
      'savedCO2': instance.savedCO2,
      'phoneNumber': instance.phoneNumber,
    };
