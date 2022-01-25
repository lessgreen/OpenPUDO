// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateUserProfileRequest _$UpdateUserProfileRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateUserProfileRequest(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      ssn: json['ssn'] as String?,
    );

Map<String, dynamic> _$UpdateUserProfileRequestToJson(
        UpdateUserProfileRequest instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'ssn': instance.ssn,
    };
