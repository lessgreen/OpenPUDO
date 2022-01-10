//
//  ColorSerializer.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 10/07/2021.
//  Copyright © 2022 Sofapps. All rights reserved.
//

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
