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
import 'package:qui_green/models/rating_model.dart';

part 'pudo_summary.g.dart';

@JsonSerializable()
class PudoSummary with PudoCardRepresentation {
  @override
  int pudoId;
  @override
  String businessName;
  @override
  String? pudoPicId;
  @override
  @JsonKey(name: 'label')
  String? computedAddress;
  @override
  RatingModel? rating;
  @override
  String? customizedAddress;

  PudoSummary({
    required this.pudoId,
    required this.businessName,
    this.computedAddress,
    this.pudoPicId,
    this.rating,
    this.customizedAddress,
  });

  factory PudoSummary.fromJson(Map<String, dynamic> json) => _$PudoSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$PudoSummaryToJson(this);
}

mixin PudoCardRepresentation {
  int get pudoId;
  String get businessName;
  String? get pudoPicId;
  String? get computedAddress;
  RatingModel? get rating;
  String? get customizedAddress;
}
