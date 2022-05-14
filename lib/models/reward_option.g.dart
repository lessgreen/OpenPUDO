// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardOption _$RewardOptionFromJson(Map<String, dynamic> json) => RewardOption(
      name: json['name'] as String,
      text: json['text'] as String,
      icon: $enumDecode(_$IconInfoTypeEnumMap, json['icon']),
      exclusive: json['exclusive'] as bool?,
      checked: json['checked'] as bool? ?? false,
      extraInfo: json['extraInfo'] == null
          ? null
          : ExtraInfo.fromJson(json['extraInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RewardOptionToJson(RewardOption instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'text': instance.text,
    'icon': _$IconInfoTypeEnumMap[instance.icon],
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('exclusive', instance.exclusive);
  writeNotNull('checked', instance.checked);
  writeNotNull('extraInfo', instance.extraInfo);
  return val;
}

const _$IconInfoTypeEnumMap = {
  IconInfoType.smile: 'smile',
  IconInfoType.card: 'card',
  IconInfoType.shopping: 'shopping',
  IconInfoType.money: 'money',
  IconInfoType.bag: 'bag',
};
