// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      createTms: json['createTms'] as String,
      showPhoneNumber: json['showPhoneNumber'] as bool,
      userId: json['userId'] as int,
      updateTms: json['updateTms'] as String,
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'createTms': instance.createTms,
      'showPhoneNumber': instance.showPhoneNumber,
      'updateTms': instance.updateTms,
      'userId': instance.userId,
    };
