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
import 'package:flutter/material.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/resources/res.dart';

class NotifySentController extends StatefulWidget {
  const NotifySentController({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  _NotifySentControllerState createState() => _NotifySentControllerState();
}

class _NotifySentControllerState extends State<NotifySentController> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBarFix.build(
            context,
            middle: Text(
              'Notifica inviata',
              style: Theme.of(context).textTheme.navBarTitle,
            ),
          ),
          child: ListView(
            children: [
              const SizedBox(
                height: Dimension.paddingL,
              ),
              Text(
                'Fatto!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: Dimension.paddingL,
              ),
              Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: AppColors.primaryColorDark,
                size: MediaQuery.of(context).size.width / 2,
              ),
              const SizedBox(
                height: Dimension.paddingL,
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(height: 1.2),
                    children: [
                      const TextSpan(
                        text: "Abbiamo inviato una notifica\nall'utente ",
                      ),
                      TextSpan(text: widget.username, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  )),
            ],
          )),
    );
  }
}
