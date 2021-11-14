// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoPackage _$PudoPackageFromJson(Map<String, dynamic> json) {
  return PudoPackage(
    packageId: json['packageId'] as int,
    createTms: json['createTms'] as String?,
    packagePicId: json['packagePicId'] as String?,
    pudoId: json['pudoId'] as int?,
    updateTms: json['updateTms'] as String?,
    userId: json['userId'] as int?,
    events: (json['events'] as List<dynamic>?)
        ?.map((e) => PudoPackageEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$PudoPackageToJson(PudoPackage instance) =>
    <String, dynamic>{
      'createTms': instance.createTms,
      'packageId': instance.packageId,
      'packagePicId': instance.packagePicId,
      'pudoId': instance.pudoId,
      'updateTms': instance.updateTms,
      'userId': instance.userId,
      'events': instance.events,
    };
