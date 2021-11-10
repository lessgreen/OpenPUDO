// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_package_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoPackageEvent _$PudoPackageEventFromJson(Map<String, dynamic> json) {
  return PudoPackageEvent(
    packageEventId: json['packageEventId'] as int,
    packageId: json['packageId'] as int,
    createTms: json['createTms'] as String?,
    notes: json['notes'] as String?,
    packageStatus:
        _$enumDecodeNullable(_$PudoPackageStatusEnumMap, json['packageStatus']),
  );
}

Map<String, dynamic> _$PudoPackageEventToJson(PudoPackageEvent instance) =>
    <String, dynamic>{
      'packageEventId': instance.packageEventId,
      'packageId': instance.packageId,
      'createTms': instance.createTms,
      'notes': instance.notes,
      'packageStatus': _$PudoPackageStatusEnumMap[instance.packageStatus],
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