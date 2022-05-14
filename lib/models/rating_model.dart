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

part 'rating_model.g.dart';

@JsonSerializable()
class RatingModel {
  int pudoId;
  double? averageScore;
  int reviewCount;

  RatingModel(
      {required this.pudoId,
      required this.averageScore,
      required this.reviewCount});

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);

  Map<String, dynamic> toJson() => _$RatingModelToJson(this);

  int get stars {
    if (averageScore == null) {
      return 0;
    }
    if (averageScore! <= 0) {
      return 0;
    } else if (averageScore! > 0 && averageScore! < 2) {
      return 1;
    } else if (averageScore! > 1 && averageScore! < 3) {
      return 2;
    } else if (averageScore! > 2 && averageScore! < 4) {
      return 3;
    } else if (averageScore! > 3 && averageScore! < 5) {
      return 4;
    } else {
      return 5;
    }
  }
}
