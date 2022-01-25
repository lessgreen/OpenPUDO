// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoNotification _$PudoNotificationFromJson(Map<String, dynamic> json) =>
    PudoNotification(
      notificationId: json['notificationId'] as int,
      createTms: json['createTms'] as String?,
      message: json['message'] as String?,
      readTms: json['readTms'] as String?,
      title: json['title'] as String?,
      optData: json['optData'],
      userId: json['userId'] as int?,
    );

Map<String, dynamic> _$PudoNotificationToJson(PudoNotification instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
      'createTms': instance.createTms,
      'message': instance.message,
      'readTms': instance.readTms,
      'title': instance.title,
      'optData': instance.optData,
      'userId': instance.userId,
    };
