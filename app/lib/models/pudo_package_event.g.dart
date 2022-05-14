// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_package_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoPackageEvent _$PudoPackageEventFromJson(Map<String, dynamic> json) =>
    PudoPackageEvent(
      packageEventId: json['packageEventId'] as int,
      packageId: json['packageId'] as int,
      createTms: json['createTms'] == null
          ? null
          : DateTime.parse(json['createTms'] as String),
      notes: json['notes'] as String?,
      packageStatus:
          $enumDecodeNullable(_$PackageStatusEnumMap, json['packageStatus']),
      packageStatusMessage: json['packageStatusMessage'] as String?,
      autoFlag: json['autoFlag'] as bool?,
    );

Map<String, dynamic> _$PudoPackageEventToJson(PudoPackageEvent instance) =>
    <String, dynamic>{
      'packageEventId': instance.packageEventId,
      'packageId': instance.packageId,
      'createTms': instance.createTms?.toIso8601String(),
      'notes': instance.notes,
      'packageStatus': _$PackageStatusEnumMap[instance.packageStatus],
      'packageStatusMessage': instance.packageStatusMessage,
      'autoFlag': instance.autoFlag,
    };

const _$PackageStatusEnumMap = {
  PackageStatus.delivered: 'delivered',
  PackageStatus.notifySent: 'notify_sent',
  PackageStatus.notified: 'notified',
  PackageStatus.collected: 'collected',
  PackageStatus.accepted: 'accepted',
  PackageStatus.expired: 'expired',
};
