//
//   scrollable_suggestions.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Wed Jan 05 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ScrollableSuggestions extends StatelessWidget {
  final bool keyboardVisible;
  final bool dismissOnDrag;

  const ScrollableSuggestions({
    Key? key,
    required this.keyboardVisible,
    required this.dismissOnDrag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 4, 16, (keyboardVisible ? 0 : 50)),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.all(Radius.circular(18))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
            child: CupertinoScrollbar(
              child: ListView(
                shrinkWrap: true,
                keyboardDismissBehavior: dismissOnDrag
                    ? ScrollViewKeyboardDismissBehavior.onDrag
                    : ScrollViewKeyboardDismissBehavior.manual,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  ListTile(
                    title: const Text('Via Pola 15'),
                    onTap: () {},
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                  const ListTile(
                    title: Text('Via Pola 15'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
