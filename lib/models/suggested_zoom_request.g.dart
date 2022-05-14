// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggested_zoom_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuggestedZoomRequest _$SuggestedZoomRequestFromJson(
        Map<String, dynamic> json) =>
    SuggestedZoomRequest(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );

Map<String, dynamic> _$SuggestedZoomRequestToJson(
        SuggestedZoomRequest instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
    };
