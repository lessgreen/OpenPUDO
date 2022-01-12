//
//  PudoPackage.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 25/08/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';
import 'package:qui_green/models/pudo_package_event.dart';

part 'pudo_package.g.dart';

@JsonSerializable()
class PudoPackage {
  String? createTms;
  final int packageId;
  String? packagePicId;
  int? pudoId;
  String? updateTms;
  int? userId;
  List<PudoPackageEvent>? events;

  PudoPackage({
    required this.packageId,
    this.createTms,
    this.packagePicId,
    this.pudoId,
    this.updateTms,
    this.userId,
    this.events,
  });
  factory PudoPackage.fromJson(Map<String, dynamic> json) => _$PudoPackageFromJson(json);
  Map<String, dynamic> toJson() => _$PudoPackageToJson(this);
}
