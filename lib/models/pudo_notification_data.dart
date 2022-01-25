//
//  PudoNotificationDataData.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 31/08/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:qui_green/models/pudo_package_event.dart';

part 'pudo_notification_data.g.dart';

enum PudoNotificationType {
  @JsonValue("PACKAGE")
  PACKAGE
}

@JsonSerializable()
class PudoNotificationData {
  String? notificationId;
  PudoPackageStatus? packageStatus;
  String? packageId;
  PudoNotificationType? notificationType;

  PudoNotificationData(
      {this.notificationId,
      this.packageStatus,
      this.packageId,
      this.notificationType});

  factory PudoNotificationData.fromJson(Map<String, dynamic> json) =>
      _$PudoNotificationDataFromJson(json);

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
