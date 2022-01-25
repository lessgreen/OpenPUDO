// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_pudos_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetPudosRequest _$GetPudosRequestFromJson(Map<String, dynamic> json) =>
    GetPudosRequest(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      zoom: json['zoom'] as int,
    );

Map<String, dynamic> _$GetPudosRequestToJson(GetPudosRequest instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
      'zoom': instance.zoom,
    };
