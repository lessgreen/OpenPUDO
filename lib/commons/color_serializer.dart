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

extension ColorSerializer on Color {
  String get hexString {
    String redValue = red.toRadixString(16);
    String greenValue = green.toRadixString(16);
    String blueValue = blue.toRadixString(16);
    if (redValue.length < 2) {
      redValue = '0$redValue';
    }
    if (greenValue.length < 2) {
      greenValue = '0$greenValue';
    }
    if (blueValue.length < 2) {
      blueValue = '0$blueValue';
    }
    return '0xff' + redValue + greenValue + blueValue;
  }

  static Color? fromString(String hexString) {
    var intParsed = int.parse(hexString);
    return Color(intParsed);
  }

  get materialColor {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = red, g = green, b = blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(value, swatch);
  }
}
