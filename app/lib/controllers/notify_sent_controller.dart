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
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/resources/res.dart';

class NotifySentController extends StatefulWidget {
  const NotifySentController({Key? key, required this.username, required this.type, required this.canGoBack}) : super(key: key);
  final String username;
  final NotifySentControllerTypes type;
  final bool canGoBack;

  @override
  State<NotifySentController> createState() => _NotifySentControllerState();
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
              mainText,
              style: Theme.of(context).textTheme.navBarTitle,
            ),
            leading: widget.canGoBack
                ? CupertinoNavigationBarBackButton(
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
          ),
          child: ListView(
            children: [
              const SizedBox(
                height: Dimension.paddingXL,
              ),
              Text(
                'secondaryLabel'.localized(context),
                style: Theme.of(context).textTheme.headline6,
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
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 3 * 2,
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '',
                        style: Theme.of(context).textTheme.subtitle1Secondary,
                        children: [
                          TextSpan(
                            text: description,
                          ),
                          TextSpan(text: widget.username, style: Theme.of(context).textTheme.subtitle1Bold),
                        ],
                      )),
                ),
              ),
            ],
          )),
    );
  }

  get mainText => 'mainLabel${widget.type.name}'.localized(context);
  get description => 'description${widget.type.name}'.localized(context);
}

// ignore: constant_identifier_names
enum NotifySentControllerTypes { PackageReceived, PackageDelivered }
