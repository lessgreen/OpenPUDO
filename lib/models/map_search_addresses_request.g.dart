// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_search_addresses_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapSearchAddressesRequest _$MapSearchAddressesRequestFromJson(
        Map<String, dynamic> json) =>
    MapSearchAddressesRequest(
      text: json['text'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MapSearchAddressesRequestToJson(
        MapSearchAddressesRequest instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
      'text': instance.text,
    };
