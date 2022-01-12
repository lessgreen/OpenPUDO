// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pudo_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PudoProfile _$PudoProfileFromJson(Map<String, dynamic> json) {
  return PudoProfile(
    businessName: json['businessName'] as String,
    contactNotes: json['contactNotes'] as String?,
    createTms: json['createTms'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    pudoId: json['pudoId'] as int?,
    updateTms: json['updateTms'] as String?,
    vat: json['vat'] as String?,
    address: json['address'] == null
        ? null
        : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
  )..profilePicId = json['profilePicId'] as String?;
}

Map<String, dynamic> _$PudoProfileToJson(PudoProfile instance) =>
    <String, dynamic>{
      'businessName': instance.businessName,
      'contactNotes': instance.contactNotes,
      'createTms': instance.createTms,
      'phoneNumber': instance.phoneNumber,
      'profilePicId': instance.profilePicId,
      'pudoId': instance.pudoId,
      'updateTms': instance.updateTms,
      'vat': instance.vat,
      'address': instance.address,
    };
