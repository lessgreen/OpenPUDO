//
//  PudoPackageEvent.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 25/08/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'pudo_package_event.g.dart';


enum PudoPackageStatus {
  @JsonValue("ACCEPTED")
  ACCEPTED,
  @JsonValue("COLLECTED")
  COLLECTED,
  @JsonValue("DELIVERED")
  DELIVERED,
  @JsonValue("EXPIRED")
  EXPIRED,
  @JsonValue("NOTIFIED")
  NOTIFIED,
  @JsonValue("RETURNED")
  RETURNED,
  @JsonValue("NOTIFY_SENT")
  NOTIFY_SENT
}

@JsonSerializable()
class PudoPackageEvent {
  final int packageEventId;
  final int packageId;
  String? createTms;
  String? notes;
  PudoPackageStatus? packageStatus;

  PudoPackageEvent({
    required this.packageEventId,
    required this.packageId,
    this.createTms,
    this.notes,
    this.packageStatus,
  });
  factory PudoPackageEvent.fromJson(Map<String, dynamic> json) => _$PudoPackageEventFromJson(json);
  Map<String, dynamic> toJson() => _$PudoPackageEventToJson(this);

  String? get packageStatusRaw {
    return packageStatus.toString().split('.').last;
  }
}
