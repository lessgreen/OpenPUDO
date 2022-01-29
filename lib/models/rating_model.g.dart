// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingModel _$RatingModelFromJson(Map<String, dynamic> json) => RatingModel(
      pudoId: json['pudoId'] as int,
      averageScore: (json['averageScore'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int,
    );

Map<String, dynamic> _$RatingModelToJson(RatingModel instance) =>
    <String, dynamic>{
      'pudoId': instance.pudoId,
      'averageScore': instance.averageScore,
      'reviewCount': instance.reviewCount,
    };
