import 'package:json_annotation/json_annotation.dart';

part 'user_preferences.g.dart';

@JsonSerializable()
class UserPreferences {
  String createTms;
  bool showPhoneNumber;
  String updateTms;
  int userId;

  UserPreferences(
      {required this.createTms,
      required this.showPhoneNumber,
      required this.userId,
      required this.updateTms});

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}
