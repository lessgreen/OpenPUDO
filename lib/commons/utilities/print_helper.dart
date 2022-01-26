import 'package:flutter/foundation.dart';

void safePrint(String val) {
  if (kDebugMode) {
    print(val);
  }
}
