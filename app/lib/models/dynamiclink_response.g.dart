// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamiclink_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicLinkResponse _$DynamicLinkResponseFromJson(Map<String, dynamic> json) =>
    DynamicLinkResponse(
      route: $enumDecode(_$DynamicLinkRouteEnumMap, json['route']),
      data: DynamicLinkData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DynamicLinkResponseToJson(
        DynamicLinkResponse instance) =>
    <String, dynamic>{
      'route': _$DynamicLinkRouteEnumMap[instance.route]!,
      'data': instance.data,
    };

const _$DynamicLinkRouteEnumMap = {
  DynamicLinkRoute.enrollProspect: 'enroll-prospect',
};

DynamicLinkData _$DynamicLinkDataFromJson(Map<String, dynamic> json) =>
    DynamicLinkData(
      accessTokenData: json['accessTokenData'] == null
          ? null
          : AccessTokenData.fromJson(
              json['accessTokenData'] as Map<String, dynamic>),
      phoneNumber: json['phoneNumber'] as String?,
      accountType: json['accountType'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      businessName: json['businessName'] as String?,
      favouritePudoId: json['favouritePudoId'] as int?,
    )..address = json['address'] == null
        ? null
        : GeoMarker.fromJson(json['address'] as Map<String, dynamic>);

Map<String, dynamic> _$DynamicLinkDataToJson(DynamicLinkData instance) =>
    <String, dynamic>{
      'accessTokenData': instance.accessTokenData,
      'phoneNumber': instance.phoneNumber,
      'accountType': instance.accountType,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'businessName': instance.businessName,
      'favouritePudoId': instance.favouritePudoId,
      'address': instance.address,
    };
