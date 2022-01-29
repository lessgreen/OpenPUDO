// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoModel _$PudoModelFromJson(Map<String, dynamic> json) => PudoModel(
      pudoId: json['pudoId'] as int,
      businessName: json['businessName'] as String?,
      pudoPicId: json['pudoPicId'] as String?,
      label: json['label'] as String?,
      rating: json['rating'] == null
          ? null
          : RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PudoModelToJson(PudoModel instance) => <String, dynamic>{
      'pudoId': instance.pudoId,
      'businessName': instance.businessName,
      'pudoPicId': instance.pudoPicId,
      'label': instance.label,
      'rating': instance.rating,
    };
