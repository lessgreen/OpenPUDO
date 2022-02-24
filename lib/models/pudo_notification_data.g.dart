// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_notification_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoNotificationData _$PudoNotificationDataFromJson(
        Map<String, dynamic> json) =>
    PudoNotificationData(
      notificationId: json['notificationId'] as String?,
      packageStatus: $enumDecodeNullable(
          _$PudoPackageStatusEnumMap, json['packageStatus']),
      packageId: json['packageId'] as String?,
      notificationType: $enumDecodeNullable(
          _$PudoNotificationTypeEnumMap, json['notificationType']),
    );

Map<String, dynamic> _$PudoNotificationDataToJson(
        PudoNotificationData instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
      'packageStatus': _$PudoPackageStatusEnumMap[instance.packageStatus],
      'packageId': instance.packageId,
      'notificationType':
          _$PudoNotificationTypeEnumMap[instance.notificationType],
    };

const _$PudoPackageStatusEnumMap = {
  PudoPackageStatus.delivered: 'delivered',
  PudoPackageStatus.notifySent: 'notify_sent',
  PudoPackageStatus.notified: 'notified',
  PudoPackageStatus.collected: 'collected',
  PudoPackageStatus.accepted: 'accepted',
  PudoPackageStatus.expired: 'expired',
};

const _$PudoNotificationTypeEnumMap = {
  PudoNotificationType.PACKAGE: 'PACKAGE',
};
