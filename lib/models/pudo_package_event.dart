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
