//
//  StringDateTime.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 31/08/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:intl/intl.dart';

extension StringDateTime on String {
  DateTime? get toDateTime {
    return DateTime.tryParse(this);
  }

  String? formattedDate([String? format]) {
    var localDate = DateTime.parse(this).toLocal();
    return DateFormat().format(localDate);
  }
}
