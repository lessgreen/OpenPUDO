// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_search_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapSearchRequest _$MapSearchRequestFromJson(Map<String, dynamic> json) {
  return MapSearchRequest(
    text: json['text'] as String,
    lat: (json['lat'] as num?)?.toDouble(),
    lon: (json['lon'] as num?)?.toDouble(),
  );
}

Map<String, dynamic> _$MapSearchRequestToJson(MapSearchRequest instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
      'text': instance.text,
    };
