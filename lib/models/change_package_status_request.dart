//
//  ChangePackageStatusRequest.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 25/08/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:json_annotation/json_annotation.dart';

part 'change_package_status_request.g.dart';

@JsonSerializable()
class ChangePackageStatusRequest {
  String? notes;

  ChangePackageStatusRequest({this.notes});
  factory ChangePackageStatusRequest.fromJson(Map<String, dynamic> json) => _$ChangePackageStatusRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChangePackageStatusRequestToJson(this);
}
