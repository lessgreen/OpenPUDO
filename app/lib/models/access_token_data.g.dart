// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_token_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessTokenData _$AccessTokenDataFromJson(Map<String, dynamic> json) =>
    AccessTokenData(
      accessToken: json['accessToken'] as String,
      expireDate: json['expireDate'] as String,
      issueDate: json['issueDate'] as String,
      accessProfile: json['accessProfile'] as String,
    );

Map<String, dynamic> _$AccessTokenDataToJson(AccessTokenData instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'expireDate': instance.expireDate,
      'issueDate': instance.issueDate,
      'accessProfile': instance.accessProfile,
    };
