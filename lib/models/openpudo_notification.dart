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

part 'openpudo_notification.g.dart';

@JsonSerializable()
class OpenPudoNotification {
  final int notificationId;
  int? userId;
  DateTime? createTms;
  DateTime? readTms;
  String? title;
  String? message;
  NotificationOptData? optData;

  OpenPudoNotification({
    required this.notificationId,
    this.userId,
    this.createTms,
    this.readTms,
    this.title,
    this.message,
    this.optData,
  });

  factory OpenPudoNotification.fromJson(Map<String, dynamic> json) => _$OpenPudoNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$OpenPudoNotificationToJson(this);

  bool get isRead {
    return readTms != null;
  }

  OpenPudoNotification copyWith({
    int? notificationId,
    int? userId,
    DateTime? createTms,
    DateTime? readTms,
    String? title,
    String? message,
    NotificationOptData? optData,
  }) =>
      OpenPudoNotification(
          notificationId: notificationId ?? this.notificationId,
          userId: userId ?? this.userId,
          createTms: createTms ?? this.createTms,
          readTms: readTms ?? this.readTms,
          title: title ?? this.title,
          message: message ?? this.message,
          optData: optData ?? this.optData);
}

enum NotificationType {
  @JsonValue("favourite")
  favourite,
  @JsonValue("package")
  package,
}

@JsonSerializable()
class NotificationOptData {
  final NotificationType? notificationType;
  String? notificationId;
  String? userId;
  String? pudoId;
  String? packageId;

  NotificationOptData({
    required this.notificationType,
    this.notificationId,
    this.userId,
    this.pudoId,
    this.packageId,
  });

  factory NotificationOptData.fromJson(Map<String, dynamic> json) => _$NotificationOptDataFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationOptDataToJson(this);
}
