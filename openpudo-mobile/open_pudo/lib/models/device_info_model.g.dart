// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceInfoModel _$DeviceInfoModelFromJson(Map<String, dynamic> json) {
  return DeviceInfoModel(
    deviceToken: json['deviceToken'] as String?,
    deviceType: json['deviceType'] as String?,
    systemName: json['systemName'] as String?,
    systemVersion: json['systemVersion'] as String?,
    model: json['model'] as String?,
    resolution: json['resolution'] as String?,
  );
}

Map<String, dynamic> _$DeviceInfoModelToJson(DeviceInfoModel instance) =>
    <String, dynamic>{
      'deviceToken': instance.deviceToken,
      'deviceType': instance.deviceType,
      'systemName': instance.systemName,
      'systemVersion': instance.systemVersion,
      'model': instance.model,
      'resolution': instance.resolution,
    };
