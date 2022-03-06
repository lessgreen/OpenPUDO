// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoProfile _$PudoProfileFromJson(Map<String, dynamic> json) => PudoProfile(
      pudoId: json['pudoId'] as int,
      businessName: json['businessName'] as String,
      contactNotes: json['contactNotes'] as String?,
      createTms: json['createTms'] as String?,
      publicPhoneNumber: json['publicPhoneNumber'] as String?,
      updateTms: json['updateTms'] as String?,
      vat: json['vat'] as String?,
      address: json['address'] == null
          ? null
          : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
      customerCount: json['customerCount'] as int?,
      pudoPicId: json['pudoPicId'] as String?,
      rewardMessage: json['rewardMessage'] as String?,
      customizedAddress: json['customizedAddress'] as String?,
    )
      ..rating = json['rating'] == null
          ? null
          : RatingModel.fromJson(json['rating'] as Map<String, dynamic>)
      ..packageCount = json['packageCount'] as int?
      ..imageUrl = json['imageUrl'] as String?;

Map<String, dynamic> _$PudoProfileToJson(PudoProfile instance) =>
    <String, dynamic>{
      'pudoId': instance.pudoId,
      'businessName': instance.businessName,
      'pudoPicId': instance.pudoPicId,
      'rating': instance.rating,
      'customizedAddress': instance.customizedAddress,
      'contactNotes': instance.contactNotes,
      'createTms': instance.createTms,
      'publicPhoneNumber': instance.publicPhoneNumber,
      'updateTms': instance.updateTms,
      'vat': instance.vat,
      'address': instance.address,
      'customerCount': instance.customerCount,
      'packageCount': instance.packageCount,
      'rewardMessage': instance.rewardMessage,
      'imageUrl': instance.imageUrl,
    };
