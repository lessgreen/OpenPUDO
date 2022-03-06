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
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/content_package_list_pudo_page.dart';
import 'package:qui_green/widgets/content_package_list_user_page.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class PackagesListController extends StatefulWidget {
  const PackagesListController({Key? key, required this.isForPudo, this.isOnReceivePack = false, this.enableHistory = false}) : super(key: key);
  final bool isOnReceivePack;
  final bool enableHistory;
  final bool isForPudo;

  @override
  _PackagesListControllerState createState() => _PackagesListControllerState();
}

class _PackagesListControllerState extends State<PackagesListController> with ConnectionAware {
  late PackagesListContentState state;

  @override
  void initState() {
    super.initState();
    if (widget.isForPudo) {
      state = PackagesListContentState.pudo;
    } else {
      state = PackagesListContentState.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (context, currentUser, _) => Material(
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBarFix.build(
            context,
            middle: Text(
              _buildCorrectTitle(),
              style: Theme.of(context).textTheme.navBarTitle,
            ),
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          child: SAScaffold(isLoading: NetworkManager.instance.networkActivity, body: _buildCorrectPage()),
        ),
      ),
    );
  }

  Widget _buildCorrectPage() {
    switch (state) {
      case PackagesListContentState.user:
        return const ContentPackagesListUserPage();
      case PackagesListContentState.pudo:
        return ContentPackagesListPudoPage(
          enableHistory: widget.enableHistory,
          isOnReceivePack: widget.isOnReceivePack,
        );
      default:
        return const SizedBox();
    }
  }

  String _buildCorrectTitle() {
    switch (state) {
      case PackagesListContentState.user:
        return "I tuoi pacchi";
      case PackagesListContentState.pudo:
        return widget.isOnReceivePack ? 'Scegli un pacco' : "Pacchi in giacenza";
      default:
        return "";
    }
  }
}

enum PackagesListContentState { user, pudo }
