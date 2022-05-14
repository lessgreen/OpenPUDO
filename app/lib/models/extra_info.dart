/*
 OpenPUDO - PUDO and Micro-delivery software for Last Mile Collaboration
 Copyright (C) 2020-2022 LESS SRL - https://less.green

 This file is part of OpenPUDO software.

 OpenPUDO is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License version 3
 as published by the Copyright Owner.

 OpenPUDO is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License version 3 for more details.

 You should have received a copy of the GNU Affero General Public License
 version 3 published by the Copyright Owner along with OpenPUDO.  
 If not, see <https://github.com/lessgreen/OpenPUDO>.
*/

import 'package:json_annotation/json_annotation.dart';

part 'extra_info.g.dart';

enum ExtraInfoType {
  @JsonValue("decimal")
  decimal,
  @JsonValue("select")
  select,
  @JsonValue("text")
  text,
}

@JsonSerializable()
class ExtraInfo {
  final String name;
  final String text;
  final ExtraInfoType type;
  @JsonKey(includeIfNull: false)
  final bool mandatoryValue;
  @JsonKey(includeIfNull: false)
  dynamic value;
  @JsonKey(includeIfNull: false)
  final double? min;
  @JsonKey(includeIfNull: false)
  final double? max;
  @JsonKey(includeIfNull: false)
  final double? scale;
  @JsonKey(includeIfNull: false)
  final double? step;
  @JsonKey(includeIfNull: false)
  final List<ExtraInfoSelectItem>? values;

  ExtraInfo({
    required this.name,
    required this.text,
    required this.type,
    required this.mandatoryValue,
    this.value,
    this.min,
    this.max,
    this.scale,
    this.step,
    this.values,
  });

  factory ExtraInfo.fromJson(Map<String, dynamic> json) => _$ExtraInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ExtraInfoToJson(this);
}

@JsonSerializable()
class ExtraInfoSelectItem {
  final String name;
  final String text;
  @JsonKey(defaultValue: false,includeIfNull: false)
  bool? checked;
  @JsonKey(includeIfNull: false)
  final ExtraInfo? extraInfo;

  ExtraInfoSelectItem({
    required this.name,
    required this.text,
    this.checked = false,
    this.extraInfo,
  });

  factory ExtraInfoSelectItem.fromJson(Map<String, dynamic> json) => _$ExtraInfoSelectItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExtraInfoSelectItemToJson(this);
}
