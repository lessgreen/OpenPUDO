// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_package_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoPackageEvent _$PudoPackageEventFromJson(Map<String, dynamic> json) =>
    PudoPackageEvent(
      packageEventId: json['packageEventId'] as int,
      packageId: json['packageId'] as int,
      createTms: json['createTms'] as String?,
      notes: json['notes'] as String?,
      packageStatus: $enumDecodeNullable(
          _$PudoPackageStatusEnumMap, json['packageStatus']),
    );

Map<String, dynamic> _$PudoPackageEventToJson(PudoPackageEvent instance) =>
    <String, dynamic>{
      'packageEventId': instance.packageEventId,
      'packageId': instance.packageId,
      'createTms': instance.createTms,
      'notes': instance.notes,
      'packageStatus': _$PudoPackageStatusEnumMap[instance.packageStatus],
    };

const _$PudoPackageStatusEnumMap = {
  PudoPackageStatus.ACCEPTED: 'ACCEPTED',
  PudoPackageStatus.COLLECTED: 'COLLECTED',
  PudoPackageStatus.DELIVERED: 'DELIVERED',
  PudoPackageStatus.EXPIRED: 'EXPIRED',
  PudoPackageStatus.NOTIFIED: 'NOTIFIED',
  PudoPackageStatus.RETURNED: 'RETURNED',
  PudoPackageStatus.NOTIFY_SENT: 'NOTIFY_SENT',
};
