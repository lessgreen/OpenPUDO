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
import 'package:provider/provider.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/content_notifications_page.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class NotificationsListController extends StatefulWidget {
  const NotificationsListController({Key? key}) : super(key: key);

  @override
  State<NotificationsListController> createState() => _NotificationsListControllerState();
}

class _NotificationsListControllerState extends State<NotificationsListController> with ConnectionAware {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (context, currentUser, _) => SAScaffold(
        isLoading: NetworkManager.instance.networkActivity,
        cupertinoBar: CupertinoNavigationBarFix.build(
          context,
          middle: Text(
            'navBarTitle'.localized(context),
            style: Theme.of(context).textTheme.navBarTitle,
          ),
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const SafeArea(child: ContentNotificationsPage()),
      ),
    );
  }
}
