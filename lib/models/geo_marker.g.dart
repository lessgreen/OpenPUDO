// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_marker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoMarker _$GeoMarkerFromJson(Map<String, dynamic> json) => GeoMarker(
      pudo: json['pudo'],
      address: json['address'] == null
          ? null
          : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      signature: json['signature'] as String?,
      distanceFromOrigin: (json['distanceFromOrigin'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$GeoMarkerToJson(GeoMarker instance) => <String, dynamic>{
      'pudo': instance.pudo,
      'address': instance.address,
      'lat': instance.lat,
      'lon': instance.lon,
      'signature': instance.signature,
      'distanceFromOrigin': instance.distanceFromOrigin,
    };
