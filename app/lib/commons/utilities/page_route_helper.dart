import 'dart:io';

import 'package:flutter/cupertino.dart';

class PageRouteHelper {
  static buildPage(Widget page) {
    if (Platform.isIOS) {
      return CupertinoPageRoute(builder: (context) => page);
    }
    return PageRouteBuilder(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (BuildContext context, _, __) {
        return page;
      },
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return SlideTransition(
          transformHitTests: false,
          child: child,
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
        );
      },
    );
  }
}
