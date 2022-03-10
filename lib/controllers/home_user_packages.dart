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
import 'package:qui_green/widgets/content_package_page.dart';
import 'package:qui_green/widgets/no_packages_widget.dart';
import 'package:qui_green/widgets/no_pudos_widget.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class HomeUserPackages extends StatefulWidget {
  const HomeUserPackages({Key? key}) : super(key: key);

  @override
  _HomeUserPackagesState createState() => _HomeUserPackagesState();
}

enum HomeUserState { hasPackages, noPackages, noPudo, unknown }

class _HomeUserPackagesState extends State<HomeUserPackages> with ConnectionAware {
  bool _hasPackages = false;

  List<Future> _buildFutures() {
    _hasPackages = (Provider.of<CurrentUser>(context, listen: false).user?.packageCount ?? 0) > 0;
    var future1 = NetworkManager.instance.getMyPudos().then((value) => (value as List).isNotEmpty).catchError((onError) => false);
    return [future1];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (_, currentUser, __) {
        return FutureBuilder(
          future: Future.wait(_buildFutures()),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            return Material(
              child: CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBarFix.build(
                  context,
                  middle: Text(
                    'defaultTitle'.localized(context, 'general'),
                    style: Theme.of(context).textTheme.navBarTitle,
                  ),
                ),
                child: SafeArea(
                  child: SAScaffold(
                    isLoading: NetworkManager.instance.networkActivity,
                    body: _buildInitialPage(snapshot.data?[0] ?? false),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  //MARK: Build widget accessories

  _buildInitialPage(bool hasPudos) {
    var newState = HomeUserState.unknown;

    if (_hasPackages) {
      newState = HomeUserState.hasPackages;
    } else if (hasPudos) {
      newState = HomeUserState.noPackages;
    } else if (!hasPudos) {
      newState = HomeUserState.noPudo;
    }
    return _buildCorrectPage(newState);
  }

  Widget _buildCorrectPage(HomeUserState? state) {
    switch (state) {
      case HomeUserState.hasPackages:
        return const ContentPackagesPage();
      case HomeUserState.noPackages:
        return const NoPackagesWidget();
      case HomeUserState.noPudo:
        return const NoPudosWidget();
      default:
        return const SizedBox();
    }
  }
}
