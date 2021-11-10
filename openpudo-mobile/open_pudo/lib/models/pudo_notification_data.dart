//
//  PudoNotificationDataData.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 31/08/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';
import 'package:open_pudo/models/pudo_package_event.dart';

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

  PudoNotificationData({this.notificationId, this.packageStatus, this.packageId, this.notificationType});
  factory PudoNotificationData.fromJson(Map<String, dynamic> json) => _$PudoNotificationDataFromJson(json);
  Map<String, dynamic> toJson() => _$PudoNotificationDataToJson(this);

  int? get notificationIdToInt {
    if (this.notificationId == null) {
      return null;
    }
    return int.tryParse(this.notificationId!);
  }

  int? get packageIdToInt {
    if (this.packageId == null) {
      return null;
    }
    return int.tryParse(this.packageId!);
  }
}
