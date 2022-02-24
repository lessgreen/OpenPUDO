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
      packageStatus: $enumDecodeNullable(
          _$PudoPackageStatusEnumMap, json['packageStatus']),
      autoFlag: json['autoFlag'] as bool?,
    );

Map<String, dynamic> _$PudoPackageEventToJson(PudoPackageEvent instance) =>
    <String, dynamic>{
      'packageEventId': instance.packageEventId,
      'packageId': instance.packageId,
      'createTms': instance.createTms?.toIso8601String(),
      'notes': instance.notes,
      'packageStatus': _$PudoPackageStatusEnumMap[instance.packageStatus],
      'autoFlag': instance.autoFlag,
    };

const _$PudoPackageStatusEnumMap = {
  PudoPackageStatus.delivered: 'delivered',
  PudoPackageStatus.notifySent: 'notify_sent',
  PudoPackageStatus.notified: 'notified',
  PudoPackageStatus.collected: 'collected',
  PudoPackageStatus.accepted: 'accepted',
  PudoPackageStatus.expired: 'expired',
};
