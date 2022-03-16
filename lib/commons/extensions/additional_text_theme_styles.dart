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

  TextStyle? get bodyTextLightSecondary => bodyTextLight?.copyWith(color: CupertinoColors.secondaryLabel);

  TextStyle? get bodyTextBold => bodyText1?.copyWith(fontWeight: FontWeight.w500);

  TextStyle? get bodyTextBoldRed => bodyTextBold?.copyWith(color: Colors.red);

  TextStyle? get bodyTextItalic => bodyText1?.copyWith(fontStyle: FontStyle.italic);

  TextStyle? get captionSmall => labelSmall?.copyWith(color: AppColors.colorGrey);

  TextStyle? get headerTitle => caption?.copyWith(color: AppColors.colorGrey, fontWeight: FontWeight.w600);

  TextStyle? get dialogButtonRefuse => headline6?.copyWith(fontWeight: FontWeight.w500);

  TextStyle? get dialogButtonAccept => headline6?.copyWith(color: AppColors.primaryColorDark, fontWeight: FontWeight.w500);

  TextStyle? get labelLargeWhite => labelLarge?.copyWith(color: Colors.white);

  TextStyle? get bodyTextItalicBoldAccent => bodyText1?.copyWith(color: AppColors.accentColor, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic);

  TextStyle? get bodyTextItalicAccent => bodyText1?.copyWith(color: AppColors.accentColor, fontStyle: FontStyle.italic);

  TextStyle? get bodyTextItalicSecondary => bodyText1?.copyWith(color: CupertinoColors.secondaryLabel, fontStyle: FontStyle.italic);

  TextStyle? get bodyTextBoldAccent => bodyText1?.copyWith(color: AppColors.accentColor, fontWeight: FontWeight.w500);

  TextStyle? get bodyText2Italic => bodyText2?.copyWith(fontWeight: FontWeight.w500);

  TextStyle? get bodyText2White => bodyText2?.copyWith(color: Colors.white);

  TextStyle? get captionItalic => caption?.copyWith(fontStyle: FontStyle.italic);

  TextStyle? get captionWhite => caption?.copyWith(color: Colors.white);

  TextStyle? get captionLightItalic => caption?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w300);

  TextStyle? get rewardOptionBody => subtitle1?.copyWith(fontSize: 15, fontWeight: FontWeight.w300, letterSpacing: 0);

  TextStyle? get subtitle1Bold => subtitle1?.copyWith(fontWeight: FontWeight.w500);

  TextStyle? get subtitle1Regular => subtitle1?.copyWith(fontWeight: FontWeight.w300);

  TextStyle? get pudoRewardPolicy => subtitle1?.copyWith(height: 2, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300);

  TextStyle? get captionSwitch => caption?.copyWith(fontStyle: FontStyle.italic, height: 1.5, letterSpacing: 0);

  TextStyle? get transparentText => bodyText1?.copyWith(fontWeight: FontWeight.w300, color: Colors.transparent);

  TextStyle? get subtitle1Secondary => subtitle1?.copyWith(color: CupertinoColors.secondaryLabel);
  TextStyle? get subtitle1Bold => subtitle1?.copyWith(fontWeight: FontWeight.w500);
}
