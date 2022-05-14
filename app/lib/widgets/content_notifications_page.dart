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
import 'package:provider/provider.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/openpudo_notification.dart';
import 'package:qui_green/view_models/content_notifications_page_viewmodel.dart';
import 'package:qui_green/widgets/deleteble_listview.dart';
import 'package:qui_green/widgets/error_screen_widget.dart';
import 'package:qui_green/widgets/notification_tile.dart';

class ContentNotificationsPage extends StatefulWidget {
  const ContentNotificationsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ContentNotificationsPage> createState() => _ContentNotificationsPageState();
}

class _ContentNotificationsPageState extends State<ContentNotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContentNotificationsPageViewModel>(
      create: (_) => ContentNotificationsPageViewModel(context),
      child: Consumer<ContentNotificationsPageViewModel>(builder: (context, viewModel, _) {
        return RefreshIndicator(
          onRefresh: () async => viewModel.refreshDidTriggered(),
          child: viewModel.errorDescription != null
              ? ErrorScreenWidget(
                  description: viewModel.errorDescription,
                )
              : viewModel.availableNotifications.isEmpty
                  ? Center(child: Text("noNotifications".localized(context)))
                  : DeletableListView<OpenPudoNotification>(
                      controller: viewModel.scrollController,
                      rowHeight: 76,
                      idGetter: (value) => value.notificationId,
                      items: viewModel.availableNotifications,
                      itemPadding: EdgeInsets.zero,
                      horizontalPadding: 0,
                      borderRadius: BorderRadius.zero,
                      itemBuilder: (value) => NotificationTile(onTap: (val) => viewModel.onNotificationTile(val), notification: value),
                      showAlertOnDelete: false,
                      onDelete: (value) => viewModel.onNotificationDelete(value),
                      alertDeleteText: "",
                      hasScrollBar: true,
                    ),
        );
      }),
    );
  }
}
