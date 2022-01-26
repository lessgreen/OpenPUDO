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

part 'pudo_notification.g.dart';

@JsonSerializable()
class PudoNotification {
  final int notificationId;
  String? createTms;
  String? message;
  String? readTms;
  String? title;
  dynamic optData;
  int? userId;

  PudoNotification({
    required this.notificationId,
    this.createTms,
    this.message,
    this.readTms,
    this.title,
    this.optData,
    this.userId,
  });
  factory PudoNotification.fromJson(Map<String, dynamic> json) => _$PudoNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$PudoNotificationToJson(this);

  bool get isRead {
    return readTms != null;
  }
}
