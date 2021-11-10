// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_marker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressMarker _$AddressMarkerFromJson(Map<String, dynamic> json) {
  return AddressMarker(
    label: json['label'] as String,
    lat: (json['lat'] as num).toDouble(),
    lon: (json['lon'] as num).toDouble(),
    precision: json['precision'] as String,
    resultId: json['resultId'] as String,
  );
}

Map<String, dynamic> _$AddressMarkerToJson(AddressMarker instance) =>
    <String, dynamic>{
      'label': instance.label,
      'lat': instance.lat,
      'lon': instance.lon,
      'precision': instance.precision,
      'resultId': instance.resultId,
    };
