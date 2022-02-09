// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoSummary _$PudoSummaryFromJson(Map<String, dynamic> json) => PudoSummary(
      businessName: json['businessName'] as String,
      label: json['label'] as String?,
      pudoId: json['pudoId'] as int?,
      pudoPicId: json['pudoPicId'] as String?,
      rating: json['rating'] == null
          ? null
          : RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PudoSummaryToJson(PudoSummary instance) =>
    <String, dynamic>{
      'businessName': instance.businessName,
      'pudoPicId': instance.pudoPicId,
      'pudoId': instance.pudoId,
      'label': instance.label,
      'rating': instance.rating,
    };
