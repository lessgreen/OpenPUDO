// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extra_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExtraInfo _$ExtraInfoFromJson(Map<String, dynamic> json) => ExtraInfo(
      name: json['name'] as String,
      text: json['text'] as String,
      type: $enumDecode(_$ExtraInfoTypeEnumMap, json['type']),
      mandatoryValue: json['mandatoryValue'] as bool,
      value: json['value'],
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      scale: (json['scale'] as num?)?.toDouble(),
      step: (json['step'] as num?)?.toDouble(),
      values: (json['values'] as List<dynamic>?)
          ?.map((e) => ExtraInfoSelectItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExtraInfoToJson(ExtraInfo instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'text': instance.text,
    'type': _$ExtraInfoTypeEnumMap[instance.type],
    'mandatoryValue': instance.mandatoryValue,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('value', instance.value);
  writeNotNull('min', instance.min);
  writeNotNull('max', instance.max);
  writeNotNull('scale', instance.scale);
  writeNotNull('step', instance.step);
  writeNotNull('values', instance.values);
  return val;
}

const _$ExtraInfoTypeEnumMap = {
  ExtraInfoType.decimal: 'decimal',
  ExtraInfoType.select: 'select',
  ExtraInfoType.text: 'text',
};

ExtraInfoSelectItem _$ExtraInfoSelectItemFromJson(Map<String, dynamic> json) =>
    ExtraInfoSelectItem(
      name: json['name'] as String,
      text: json['text'] as String,
      checked: json['checked'] as bool? ?? false,
      extraInfo: json['extraInfo'] == null
          ? null
          : ExtraInfo.fromJson(json['extraInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExtraInfoSelectItemToJson(ExtraInfoSelectItem instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'text': instance.text,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('checked', instance.checked);
  writeNotNull('extraInfo', instance.extraInfo);
  return val;
}
