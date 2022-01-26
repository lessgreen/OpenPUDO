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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qui_green/commons/color_serializer.dart';
import 'package:qui_green/resources/res.dart';

class MyAppTheme {
  static const fontFamilyName = 'Roboto';

  static ThemeData themeData(BuildContext context) {
    return ThemeData(
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.all(18)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(34.0),
                  side: const BorderSide(color: AppColors.primaryColorDark),
                ),
              ),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.bodyText2),
              backgroundColor: MaterialStateProperty.all(AppColors.primaryColorDark))),
      textTheme: TextTheme(
        headline1: Theme.of(context).textTheme.headline1?.copyWith(letterSpacing: Dimension.letterSpacing),
        headline2: Theme.of(context).textTheme.headline2?.copyWith(letterSpacing: Dimension.letterSpacing),
        headline3: Theme.of(context).textTheme.headline3?.copyWith(letterSpacing: Dimension.letterSpacing),
        headline4: Theme.of(context).textTheme.headline4?.copyWith(letterSpacing: Dimension.letterSpacing),
        headline5: Theme.of(context).textTheme.headline5?.copyWith(letterSpacing: Dimension.letterSpacing),
        headline6: Theme.of(context).textTheme.headline6?.copyWith(letterSpacing: Dimension.letterSpacing),
        subtitle1: Theme.of(context).textTheme.subtitle1?.copyWith(letterSpacing: Dimension.letterSpacing),
        subtitle2: Theme.of(context).textTheme.subtitle2?.copyWith(letterSpacing: Dimension.letterSpacing),
        bodyText1: Theme.of(context).textTheme.bodyText1?.copyWith(letterSpacing: Dimension.letterSpacing),
        bodyText2: Theme.of(context).textTheme.bodyText2?.copyWith(letterSpacing: Dimension.letterSpacing),
        button: Theme.of(context).textTheme.button?.copyWith(letterSpacing: Dimension.letterSpacing),
        caption: Theme.of(context).textTheme.caption?.copyWith(letterSpacing: Dimension.letterSpacing),
        overline: Theme.of(context).textTheme.overline?.copyWith(letterSpacing: Dimension.letterSpacing),
      ),
      primarySwatch: AppColors.primarySwatch.materialColor,
      fontFamily: fontFamilyName,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSwatch(
        accentColor: AppColors.accentColor.materialColor,
        cardColor: AppColors.accentColor.materialColor,
        primaryColorDark: AppColors.primaryColorDark.materialColor,
        primarySwatch: AppColors.primarySwatch.materialColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark), // 2
      ),
      buttonTheme: ButtonThemeData(
        colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.white), // Text color
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(foregroundColor: Colors.white, elevation: 0),
    );
  }

  static ThemeData darkThemeData(BuildContext context) {
    return ThemeData(
      fontFamily: fontFamilyName,
      primarySwatch: AppColors.primarySwatch.materialColor,
      colorScheme: ColorScheme.fromSwatch(
        accentColor: AppColors.accentColor.materialColor,
        cardColor: AppColors.accentColor.materialColor,
        primaryColorDark: AppColors.primaryColorDark.materialColor,
        primarySwatch: AppColors.primarySwatch.materialColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark), // 2
      ),
      buttonTheme: ButtonThemeData(
        colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.white), // Text color
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(foregroundColor: Colors.white, elevation: 0),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.all(18)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(34.0),
                  side: const BorderSide(color: AppColors.primaryColorDark),
                ),
              ),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.bodyText2),
              backgroundColor: MaterialStateProperty.all(AppColors.primaryColorDark))),
      textTheme: TextTheme(
        headline1: Theme.of(context).textTheme.headline1?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        headline2: Theme.of(context).textTheme.headline2?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        headline3: Theme.of(context).textTheme.headline3?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        headline4: Theme.of(context).textTheme.headline4?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        headline5: Theme.of(context).textTheme.headline5?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        headline6: Theme.of(context).textTheme.headline6?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        subtitle1: Theme.of(context).textTheme.subtitle1?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        subtitle2: Theme.of(context).textTheme.subtitle2?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        bodyText1: Theme.of(context).textTheme.bodyText1?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        bodyText2: Theme.of(context).textTheme.bodyText2?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        button: Theme.of(context).textTheme.button?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        caption: Theme.of(context).textTheme.caption?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
        overline: Theme.of(context).textTheme.overline?.copyWith(letterSpacing: Dimension.letterSpacing, color: Colors.white),
      ),
      brightness: Brightness.dark,
    );
  }
}
