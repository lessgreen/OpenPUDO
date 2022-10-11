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
import 'package:qui_green/resources/res.dart';

//https://github.com/flutter/flutter/issues/42759
//TODO: Should be checked on next Flutter release if still required.

extension CupertinoNavigationBarFix on CupertinoNavigationBar {
  static CupertinoNavigationBar build(
    BuildContext context, {
    Brightness? brightness = Brightness.dark,
    EdgeInsetsDirectional? padding = EdgeInsetsDirectional.zero,
    Color? backgroundColor = AppColors.primaryColorDark,
    Widget? leading,
    Widget? middle,
    Widget? trailing,
    bool automaticallyImplyLeading = true,
    bool automaticallyImplyMiddle = true,
    String? previousPageTitle,
    Border? border,
    bool transitionBetweenRoutes = true,
  }) {
    return CupertinoNavigationBar(
      padding: padding,
      brightness: brightness,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      automaticallyImplyMiddle: automaticallyImplyMiddle,
      previousPageTitle: previousPageTitle,
      border: border,
      transitionBetweenRoutes: transitionBetweenRoutes,
      leading: leading != null ? MediaQuery(data: MediaQueryData(textScaleFactor: MediaQuery.textScaleFactorOf(context)), child: leading) : null,
      trailing: trailing != null ? MediaQuery(data: MediaQueryData(textScaleFactor: MediaQuery.textScaleFactorOf(context)), child: trailing) : null,
      middle: middle != null ? MediaQuery(data: MediaQueryData(textScaleFactor: MediaQuery.textScaleFactorOf(context)), child: middle) : null,
    );
  }
}
