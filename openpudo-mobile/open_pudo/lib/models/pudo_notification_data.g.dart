// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_notification_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoNotificationData _$PudoNotificationDataFromJson(Map<String, dynamic> json) {
  return PudoNotificationData(
    notificationId: json['notificationId'] as String?,
    packageStatus:
        _$enumDecodeNullable(_$PudoPackageStatusEnumMap, json['packageStatus']),
    packageId: json['packageId'] as String?,
    notificationType: _$enumDecodeNullable(
        _$PudoNotificationTypeEnumMap, json['notificationType']),
  );
}

Map<String, dynamic> _$PudoNotificationDataToJson(
        PudoNotificationData instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
      'packageStatus': _$PudoPackageStatusEnumMap[instance.packageStatus],
      'packageId': instance.packageId,
      'notificationType':
          _$PudoNotificationTypeEnumMap[instance.notificationType],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$PudoPackageStatusEnumMap = {
  PudoPackageStatus.ACCEPTED: 'ACCEPTED',
  PudoPackageStatus.COLLECTED: 'COLLECTED',
  PudoPackageStatus.DELIVERED: 'DELIVERED',
  PudoPackageStatus.EXPIRED: 'EXPIRED',
  PudoPackageStatus.NOTIFIED: 'NOTIFIED',
  PudoPackageStatus.RETURNED: 'RETURNED',
  PudoPackageStatus.NOTIFY_SENT: 'NOTIFY_SENT',
};

const _$PudoNotificationTypeEnumMap = {
  PudoNotificationType.PACKAGE: 'PACKAGE',
};
