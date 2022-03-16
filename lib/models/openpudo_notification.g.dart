// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openpudo_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenPudoNotification _$OpenPudoNotificationFromJson(
        Map<String, dynamic> json) =>
    OpenPudoNotification(
      notificationId: json['notificationId'] as int,
      userId: json['userId'] as int?,
      createTms: json['createTms'] as String?,
      readTms: json['readTms'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      optData: json['optData'] == null
          ? null
          : NotificationOptData.fromJson(
              json['optData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenPudoNotificationToJson(
        OpenPudoNotification instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
      'userId': instance.userId,
      'createTms': instance.createTms,
      'readTms': instance.readTms,
      'title': instance.title,
      'message': instance.message,
      'optData': instance.optData,
    };

NotificationOptData _$NotificationOptDataFromJson(Map<String, dynamic> json) =>
    NotificationOptData(
      notificationType: $enumDecodeNullable(
          _$NotificationTypeEnumMap, json['notificationType']),
      notificationId: json['notificationId'] as String?,
      userId: json['userId'] as String?,
      pudoId: json['pudoId'] as String?,
      packageId: json['packageId'] as String?,
    );

Map<String, dynamic> _$NotificationOptDataToJson(
        NotificationOptData instance) =>
    <String, dynamic>{
      'notificationType': _$NotificationTypeEnumMap[instance.notificationType],
      'notificationId': instance.notificationId,
      'userId': instance.userId,
      'pudoId': instance.pudoId,
      'packageId': instance.packageId,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.favourite: 'favourite',
  NotificationType.package: 'package',
};
