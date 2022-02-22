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

Map<String, dynamic> _$ExtraInfoToJson(ExtraInfo instance) => <String, dynamic>{
      'name': instance.name,
      'text': instance.text,
      'type': _$ExtraInfoTypeEnumMap[instance.type],
      'mandatoryValue': instance.mandatoryValue,
      'value': instance.value,
      'min': instance.min,
      'max': instance.max,
      'scale': instance.scale,
      'step': instance.step,
      'values': instance.values,
    };

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

Map<String, dynamic> _$ExtraInfoSelectItemToJson(
        ExtraInfoSelectItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'text': instance.text,
      'checked': instance.checked,
      'extraInfo': instance.extraInfo,
    };
