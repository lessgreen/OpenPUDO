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

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('pudoId', instance.pudoId);
  writeNotNull('city', instance.city);
  writeNotNull('country', instance.country);
  writeNotNull('label', instance.label);
  writeNotNull('lat', instance.lat);
  writeNotNull('lon', instance.lon);
  writeNotNull('province', instance.province);
  writeNotNull('street', instance.street);
  writeNotNull('streetNum', instance.streetNum);
  writeNotNull('zipCode', instance.zipCode);
  return val;
}
