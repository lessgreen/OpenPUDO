// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistrationRequest _$RegistrationRequestFromJson(Map<String, dynamic> json) {
  return RegistrationRequest(
    email: json['email'] as String?,
    password: json['password'] as String,
    phoneNumber: json['phoneNumber'] as String?,
    username: json['username'] as String?,
    user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    pudo: json['pudo'] == null
        ? null
        : PudoProfile.fromJson(json['pudo'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RegistrationRequestToJson(
        RegistrationRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'phoneNumber': instance.phoneNumber,
      'username': instance.username,
      'user': instance.user,
      'pudo': instance.pudo,
    };
