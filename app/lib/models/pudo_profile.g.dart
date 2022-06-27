// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoProfile _$PudoProfileFromJson(Map<String, dynamic> json) => PudoProfile(
      pudoId: json['pudoId'] as int,
      businessName: json['businessName'] as String,
      email: json['email'] as String?,
      createTms: json['createTms'] as String?,
      publicPhoneNumber: json['publicPhoneNumber'] as String?,
      updateTms: json['updateTms'] as String?,
      address: json['address'] == null
          ? null
          : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
      customerCount: json['customerCount'] as int?,
      packageCount: json['packageCount'] as int?,
      savedCO2: json['savedCO2'] as String?,
      pudoPicId: json['pudoPicId'] as String?,
      rewardMessage: json['rewardMessage'] as String?,
      customizedAddress: json['customizedAddress'] as String?,
    )
      ..rating = json['rating'] == null
          ? null
          : RatingModel.fromJson(json['rating'] as Map<String, dynamic>)
      ..imageUrl = json['imageUrl'] as String?;

Map<String, dynamic> _$PudoProfileToJson(PudoProfile instance) =>
    <String, dynamic>{
      'pudoId': instance.pudoId,
      'businessName': instance.businessName,
      'email': instance.email,
      'pudoPicId': instance.pudoPicId,
      'rating': instance.rating,
      'customizedAddress': instance.customizedAddress,
      'createTms': instance.createTms,
      'publicPhoneNumber': instance.publicPhoneNumber,
      'updateTms': instance.updateTms,
      'address': instance.address,
      'customerCount': instance.customerCount,
      'packageCount': instance.packageCount,
      'savedCO2': instance.savedCO2,
      'rewardMessage': instance.rewardMessage,
      'imageUrl': instance.imageUrl,
    };
