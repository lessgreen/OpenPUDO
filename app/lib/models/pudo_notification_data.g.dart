// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_notification_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoNotificationData _$PudoNotificationDataFromJson(
        Map<String, dynamic> json) =>
    PudoNotificationData(
      notificationId: json['notificationId'] as String?,
      packageStatus:
          $enumDecodeNullable(_$PackageStatusEnumMap, json['packageStatus']),
      packageId: json['packageId'] as String?,
      notificationType: $enumDecodeNullable(
          _$PudoNotificationTypeEnumMap, json['notificationType']),
    );

Map<String, dynamic> _$PudoNotificationDataToJson(
        PudoNotificationData instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
      'packageStatus': _$PackageStatusEnumMap[instance.packageStatus],
      'packageId': instance.packageId,
      'notificationType':
          _$PudoNotificationTypeEnumMap[instance.notificationType],
    };

const _$PackageStatusEnumMap = {
  PackageStatus.delivered: 'delivered',
  PackageStatus.notifySent: 'notify_sent',
  PackageStatus.notified: 'notified',
  PackageStatus.collected: 'collected',
  PackageStatus.accepted: 'accepted',
  PackageStatus.expired: 'expired',
};

const _$PudoNotificationTypeEnumMap = {
  PudoNotificationType.PACKAGE: 'PACKAGE',
};
