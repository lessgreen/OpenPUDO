// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSummary _$UserSummaryFromJson(Map<String, dynamic> json) => UserSummary(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      customerSuffix: json['customerSuffix'] as String?,
      profilePicId: json['profilePicId'] as String?,
      userId: json['userId'] as int?,
    );

Map<String, dynamic> _$UserSummaryToJson(UserSummary instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profilePicId': instance.profilePicId,
      'customerSuffix': instance.customerSuffix,
      'userId': instance.userId,
    };
