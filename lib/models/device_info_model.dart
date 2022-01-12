//
//  DeviceInfoModel.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'device_info_model.g.dart';

@JsonSerializable()
class DeviceInfoModel {
  String? deviceToken;
  String? deviceType;
  String? systemName;
  String? systemVersion;
  String? model;
  String? resolution;

  DeviceInfoModel({this.deviceToken, this.deviceType, this.systemName, this.systemVersion, this.model, this.resolution});
  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) => _$DeviceInfoModelFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceInfoModelToJson(this);
}
