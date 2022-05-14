// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_pudo_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePudoRequest _$UpdatePudoRequestFromJson(Map<String, dynamic> json) =>
    UpdatePudoRequest(
      pudo: json['pudo'] == null
          ? null
          : PudoRequest.fromJson(json['pudo'] as Map<String, dynamic>),
      addressMarker: json['addressMarker'] == null
          ? null
          : PudoAddressMarker.fromJson(
              json['addressMarker'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdatePudoRequestToJson(UpdatePudoRequest instance) =>
    <String, dynamic>{
      'pudo': instance.pudo,
      'addressMarker': instance.addressMarker,
    };

PudoRequest _$PudoRequestFromJson(Map<String, dynamic> json) => PudoRequest(
      businessName: json['businessName'] as String,
      publicPhoneNumber: json['publicPhoneNumber'] as String,
    );

Map<String, dynamic> _$PudoRequestToJson(PudoRequest instance) =>
    <String, dynamic>{
      'businessName': instance.businessName,
      'publicPhoneNumber': instance.publicPhoneNumber,
    };

PudoAddressMarker _$PudoAddressMarkerFromJson(Map<String, dynamic> json) =>
    PudoAddressMarker(
      signature: json['signature'] as String,
      address: AddressModel.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PudoAddressMarkerToJson(PudoAddressMarker instance) =>
    <String, dynamic>{
      'signature': instance.signature,
      'address': instance.address,
    };
