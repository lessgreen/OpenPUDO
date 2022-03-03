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
import 'package:intl/intl.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/commons/utilities/url_launcher_helper.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/table_view_cell.dart';

class UserDetailController extends StatefulWidget {
  const UserDetailController({Key? key, required this.userModel}) : super(key: key);
  final UserProfile userModel;

  @override
  _UserDetailControllerState createState() => _UserDetailControllerState();
}

class _UserDetailControllerState extends State<UserDetailController> with ConnectionAware {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBarFix.build(
          context,
          middle: Text(
            'I tuoi utenti',
            style: Theme.of(context).textTheme.navBarTitle,
          ),
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CustomNetworkImage(height: 150, width: 150, fit: BoxFit.cover, url: widget.userModel.profilePicId),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                "${widget.userModel.firstName} ${widget.userModel.lastName}",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Utente dal ${widget.userModel.createTms != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.userModel.createTms!)) : " "}',
                style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: AppColors.primaryTextColor),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            if (widget.userModel.phoneNumber != null)
              TableViewCell(
                  showTopDivider: true,
                  leading: const Icon(
                    CupertinoIcons.phone_fill,
                    color: AppColors.cardColor,
                    size: 26,
                  ),
                  title: widget.userModel.phoneNumber,
                  onTap: _openModal),
          ],
        ),
      ),
    );
  }

  void _openModal() {
    SAAlertDialog.displayModalWithButtons(context, "Scegli un'azione", [
      CupertinoActionSheetAction(
        child: const Text('Chiama al telefono'),
        onPressed: () {
          UrlLauncherHelper.launchUrl(UrlTypes.tel, widget.userModel.phoneNumber!);
        },
      ),
      CupertinoActionSheetAction(
        child: const Text('Invia un messaggio'),
        onPressed: () {
          UrlLauncherHelper.launchUrl(UrlTypes.sms, widget.userModel.phoneNumber!);
        },
      ),
      CupertinoActionSheetAction(
        child: const Text('Invia un WhatsApp'),
        onPressed: () {
          UrlLauncherHelper.launchUrl(UrlTypes.whatsapp, widget.userModel.phoneNumber!);
        },
      )
    ]);
  }
}
