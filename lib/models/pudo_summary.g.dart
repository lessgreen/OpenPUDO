// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoSummary _$PudoSummaryFromJson(Map<String, dynamic> json) => PudoSummary(
      pudoId: json['pudoId'] as int,
      businessName: json['businessName'] as String,
      label: json['label'] as String?,
      pudoPicId: json['pudoPicId'] as String?,
      rating: json['rating'] == null
          ? null
          : RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
      customizedAddress: json['customizedAddress'] as String?,
    );

Map<String, dynamic> _$PudoSummaryToJson(PudoSummary instance) =>
    <String, dynamic>{
      'pudoId': instance.pudoId,
      'businessName': instance.businessName,
      'pudoPicId': instance.pudoPicId,
      'label': instance.label,
      'rating': instance.rating,
      'customizedAddress': instance.customizedAddress,
    };
