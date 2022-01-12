// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_pudo_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePudoRequest _$UpdatePudoRequestFromJson(Map<String, dynamic> json) {
  return UpdatePudoRequest(
    businessName: json['businessName'] as String,
    contactNotes: json['contactNotes'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    vat: json['vat'] as String?,
  );
}

Map<String, dynamic> _$UpdatePudoRequestToJson(UpdatePudoRequest instance) =>
    <String, dynamic>{
      'businessName': instance.businessName,
      'contactNotes': instance.contactNotes,
      'phoneNumber': instance.phoneNumber,
      'vat': instance.vat,
    };
