// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageSummary _$PackageSummaryFromJson(Map<String, dynamic> json) =>
    PackageSummary(
      packageId: json['packageId'] as int,
      createTms: json['createTms'] == null
          ? null
          : DateTime.parse(json['createTms'] as String),
      packagePicId: json['packagePicId'] as String?,
      packageName: json['packageName'] as String?,
      packageStatus:
          $enumDecodeNullable(_$PackageStatusEnumMap, json['packageStatus']),
      pudoId: json['pudoId'] as int?,
      businessName: json['businessName'] as String?,
      label: json['label'] as String?,
      userId: json['userId'] as int?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      customerSuffix: json['customerSuffix'] as String?,
    );

Map<String, dynamic> _$PackageSummaryToJson(PackageSummary instance) =>
    <String, dynamic>{
      'packageId': instance.packageId,
      'createTms': instance.createTms?.toIso8601String(),
      'packagePicId': instance.packagePicId,
      'packageName': instance.packageName,
      'packageStatus': _$PackageStatusEnumMap[instance.packageStatus],
      'pudoId': instance.pudoId,
      'businessName': instance.businessName,
      'label': instance.label,
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'customerSuffix': instance.customerSuffix,
    };

const _$PackageStatusEnumMap = {
  PackageStatus.delivered: 'delivered',
  PackageStatus.notifySent: 'notify_sent',
  PackageStatus.notified: 'notified',
  PackageStatus.collected: 'collected',
  PackageStatus.accepted: 'accepted',
  PackageStatus.expired: 'expired',
};
