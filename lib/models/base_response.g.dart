// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OPBaseResponse _$OPBaseResponseFromJson(Map<String, dynamic> json) {
  return OPBaseResponse(
    executionId: json['executionId'] as String?,
    returnCode: json['returnCode'] as int,
    message: json['message'] as String?,
    payload: json['payload'],
  );
}

Map<String, dynamic> _$OPBaseResponseToJson(OPBaseResponse instance) =>
    <String, dynamic>{
      'executionId': instance.executionId,
      'returnCode': instance.returnCode,
      'message': instance.message,
      'payload': instance.payload,
    };
