// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
      pudoId: json['pudoId'] as int?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      label: json['label'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      province: json['province'] as String?,
      street: json['street'] as String?,
      streetNum: json['streetNum'] as String?,
      zipCode: json['zipCode'] as String?,
    );

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'pudoId': instance.pudoId,
      'city': instance.city,
      'country': instance.country,
      'label': instance.label,
      'lat': instance.lat,
      'lon': instance.lon,
      'province': instance.province,
      'street': instance.street,
      'streetNum': instance.streetNum,
      'zipCode': instance.zipCode,
    };
