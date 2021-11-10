// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generic_marker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenericMarker _$GenericMarkerFromJson(Map<String, dynamic> json) {
  return GenericMarker(
    marker: json['marker'],
    type: json['type'] as String,
    executionId: json['executionId'] as String?,
    message: json['message'] as String?,
    returnCode: json['returnCode'] as int?,
  );
}

Map<String, dynamic> _$GenericMarkerToJson(GenericMarker instance) =>
    <String, dynamic>{
      'marker': instance.marker,
      'type': instance.type,
      'executionId': instance.executionId,
      'message': instance.message,
      'returnCode': instance.returnCode,
    };
