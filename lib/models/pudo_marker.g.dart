// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_marker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoMarker _$PudoMarkerFromJson(Map<String, dynamic> json) => PudoMarker(
      pudo: PudoMarkerData.fromJson(json['pudo'] as Map<String, dynamic>),
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      distanceFromOrigin: (json['distanceFromOrigin'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PudoMarkerToJson(PudoMarker instance) =>
    <String, dynamic>{
      'pudo': instance.pudo,
      'lat': instance.lat,
      'lon': instance.lon,
      'distanceFromOrigin': instance.distanceFromOrigin,
    };

PudoMarkerData _$PudoMarkerDataFromJson(Map<String, dynamic> json) =>
    PudoMarkerData(
      pudoId: json['pudoId'] as int,
      businessName: json['businessName'] as String?,
      pudoPicId: json['pudoPicId'] as String?,
      label: json['label'] as String?,
      rating: json['rating'] == null
          ? null
          : PudoMarkerRating.fromJson(json['rating'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PudoMarkerDataToJson(PudoMarkerData instance) =>
    <String, dynamic>{
      'pudoId': instance.pudoId,
      'businessName': instance.businessName,
      'pudoPicId': instance.pudoPicId,
      'label': instance.label,
      'rating': instance.rating,
    };

PudoMarkerRating _$PudoMarkerRatingFromJson(Map<String, dynamic> json) =>
    PudoMarkerRating(
      pudoId: json['pudoId'] as int,
      reviewCount: json['reviewCount'] as int?,
      averageScore: json['averageScore'] as int?,
    );

Map<String, dynamic> _$PudoMarkerRatingToJson(PudoMarkerRating instance) =>
    <String, dynamic>{
      'pudoId': instance.pudoId,
      'reviewCount': instance.reviewCount,
      'averageScore': instance.averageScore,
    };
