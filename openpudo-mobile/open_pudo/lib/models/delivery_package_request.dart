//
//  DeliveryPackageRequest.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 25/08/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'delivery_package_request.g.dart';

@JsonSerializable()
class DeliveryPackageRequest {
  final int userId;
  String? notes;
  String? packagePicId;

  DeliveryPackageRequest({
    required this.userId,
    this.notes,
    this.packagePicId,
  });
  factory DeliveryPackageRequest.fromJson(Map<String, dynamic> json) => _$DeliveryPackageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryPackageRequestToJson(this);
}
