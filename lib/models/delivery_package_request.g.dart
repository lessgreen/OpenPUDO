// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_package_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryPackageRequest _$DeliveryPackageRequestFromJson(
        Map<String, dynamic> json) =>
    DeliveryPackageRequest(
      userId: json['userId'] as int,
      notes: json['notes'] as String?,
      packagePicId: json['packagePicId'] as String?,
    );

Map<String, dynamic> _$DeliveryPackageRequestToJson(
        DeliveryPackageRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'notes': instance.notes,
      'packagePicId': instance.packagePicId,
    };
