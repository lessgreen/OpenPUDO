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

part 'package_summary.g.dart';

@JsonSerializable()
class PackageSummary {
  final int packageId;
  final DateTime? createTms;
  final String? packagePicId;
  final String? packageName;
  final PackageStatus? packageStatus;
  final int? pudoId;
  final String? businessName;
  final String? label;
  final int? userId;
  final String? firstName;
  final String? lastName;
  final String? customerSuffix;

  PackageSummary(
      {required this.packageId,
      this.createTms,
      this.packagePicId,
      this.packageName,
      this.packageStatus,
      this.pudoId,
      this.businessName,
      this.label,
      this.userId,
      this.firstName,
      this.lastName,
      this.customerSuffix});

  factory PackageSummary.fromJson(Map<String, dynamic> json) => _$PackageSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$PackageSummaryToJson(this);
}

enum PackageStatus {
  @JsonValue("delivered")
  delivered,
  @JsonValue("notify_sent")
  notifySent,
  @JsonValue("notified")
  notified,
  @JsonValue("collected")
  collected,
  @JsonValue("accepted")
  accepted,
  @JsonValue("expired")
  expired,
}
