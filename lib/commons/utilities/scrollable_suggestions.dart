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
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: const BorderRadius.all(Radius.circular(18))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
            child: CupertinoScrollbar(
              child: ListView(
                shrinkWrap: true,
                keyboardDismissBehavior: dismissOnDrag ? ScrollViewKeyboardDismissBehavior.onDrag : ScrollViewKeyboardDismissBehavior.manual,
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
