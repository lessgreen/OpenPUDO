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

// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:qui_green/models/pudo_package_event.dart';

import 'package_summary.dart';

part 'pudo_notification_data.g.dart';

enum PudoNotificationType {
  @JsonValue("PACKAGE")
  PACKAGE
}

@JsonSerializable()
class PudoNotificationData {
  String? notificationId;
  PackageStatus? packageStatus;
  String? packageId;
  PudoNotificationType? notificationType;

  PudoNotificationData({this.notificationId, this.packageStatus, this.packageId, this.notificationType});

  factory PudoNotificationData.fromJson(Map<String, dynamic> json) => _$PudoNotificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$PudoNotificationDataToJson(this);

  int? get notificationIdToInt {
    if (notificationId == null) {
      return null;
    }
    return int.tryParse(notificationId!);
  }

  int? get packageIdToInt {
    if (packageId == null) {
      return null;
    }
    return int.tryParse(packageId!);
  }
}
