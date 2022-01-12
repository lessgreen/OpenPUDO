//
//  PudoNotification.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 24/08/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

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
