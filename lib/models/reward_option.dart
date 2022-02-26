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

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qui_green/models/extra_info.dart';

part 'reward_option.g.dart';

enum IconInfoType {
  @JsonValue("smile")
  smile,
  @JsonValue("card")
  card,
  @JsonValue("shopping")
  shopping,
  @JsonValue("money")
  money,
  @JsonValue("bag")
  bag,
}

@JsonSerializable()
class RewardOption {
  final String name;
  final String text;
  final IconInfoType icon;
  @JsonKey(includeIfNull: false)
  final bool? exclusive;
  @JsonKey(defaultValue: false,includeIfNull: false)
  bool? checked;
  @JsonKey(includeIfNull: false)
  final ExtraInfo? extraInfo;

  RewardOption({
    required this.name,
    required this.text,
    required this.icon,
    required this.exclusive,
    required this.checked,
    this.extraInfo,
  });

  factory RewardOption.fromJson(Map<String, dynamic> json) => _$RewardOptionFromJson(json);

  Map<String, dynamic> toJson() => _$RewardOptionToJson(this);

  IconData get iconData {
    switch (icon) {
      case IconInfoType.smile:
        return Icons.emoji_emotions;
      case IconInfoType.card:
        return Icons.credit_card;
      case IconInfoType.shopping:
        return Icons.shopping_bag;
      case IconInfoType.money:
        return Icons.monetization_on;
      case IconInfoType.bag:
        return Icons.shopping_bag;
      default:
        return Icons.emoji_emotions;
    }
  }
}
