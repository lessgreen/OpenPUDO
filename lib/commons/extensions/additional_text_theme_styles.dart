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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';

extension AdditionalTextTheme on TextTheme {
  TextStyle? get navBarTitle => headline6?.copyWith(color: Colors.white, fontWeight: FontWeight.w400);

  TextStyle? get navBarTitleDark => headline6?.copyWith(color: CupertinoColors.label, fontWeight: FontWeight.w400);

  TextStyle? get bodyTextLight => bodyText1?.copyWith(fontWeight: FontWeight.w300);

  TextStyle? get bodyTextBold => bodyText1?.copyWith(fontWeight: FontWeight.w500);

  TextStyle? get bodyTextItalic => bodyText1?.copyWith(fontStyle: FontStyle.italic);
  TextStyle? get dialogButtonRefuse => headline6?.copyWith(fontWeight: FontWeight.w500);
  TextStyle? get dialogButtonAccept => headline6?.copyWith(color: AppColors.primaryColorDark, fontWeight: FontWeight.w500);
}
