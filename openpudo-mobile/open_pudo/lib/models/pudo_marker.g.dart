// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_marker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoMarker _$PudoMarkerFromJson(Map<String, dynamic> json) {
  return PudoMarker(
    businessName: json['businessName'] as String,
    pudoId: json['pudoId'] as int,
    label: json['label'] as String?,
    lat: (json['lat'] as num?)?.toDouble(),
    lon: (json['lon'] as num?)?.toDouble(),
  );
}

Map<String, dynamic> _$PudoMarkerToJson(PudoMarker instance) =>
    <String, dynamic>{
      'businessName': instance.businessName,
      'pudoId': instance.pudoId,
      'label': instance.label,
      'lat': instance.lat,
      'lon': instance.lon,
    };