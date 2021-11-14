//
//  ScrollKeyboardCloser.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A widget that listens for [ScrollNotification]s bubbling up the tree
/// and close the keyboard on user scroll.
class ScrollKeyboardCloser extends StatelessWidget {
  final Widget child;

  ScrollKeyboardCloser({required this.child});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is UserScrollNotification && scrollNotification.direction == ScrollDirection.forward) {
          // close keyboard
          FocusScope.of(context).unfocus();
        }
        return false;
      },
      child: child,
    );
  }
}
