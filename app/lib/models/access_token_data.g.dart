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
      accessProfile:
          $enumDecode(_$AccessProfileTypeEnumMap, json['accessProfile']),
    );

Map<String, dynamic> _$AccessTokenDataToJson(AccessTokenData instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'expireDate': instance.expireDate,
      'issueDate': instance.issueDate,
      'accessProfile': _$AccessProfileTypeEnumMap[instance.accessProfile]!,
    };

const _$AccessProfileTypeEnumMap = {
  AccessProfileType.guest: 'guest',
  AccessProfileType.pudo: 'pudo',
  AccessProfileType.customer: 'customer',
};
