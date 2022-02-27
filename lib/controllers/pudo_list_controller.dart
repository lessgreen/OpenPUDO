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
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/utilities/network_error_helper.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/pudo_summary.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/deleteble_listview.dart';
import 'package:qui_green/widgets/no_pudos_widget.dart';
import 'package:qui_green/widgets/pudo_map_card.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class PudoListController extends StatefulWidget {
  const PudoListController({Key? key}) : super(key: key);

  @override
  _PudoListControllerState createState() => _PudoListControllerState();
}

class _PudoListControllerState extends State<PudoListController> {
  List<PudoSummary>? pudoList;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (context, currentUser, _) => FutureBuilder<void>(
        future: _getPudos(),
        builder: (context, snapshot) => Material(
          child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBarFix.build(
              context,
              middle: Text(
                'I tuoi pudo',
                style: Theme.of(context).textTheme.navBarTitle,
              ),
              leading: CupertinoNavigationBarBackButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            //ClipPath is used to avoid the scrolling cards to go outside the screen
            //and being visible when popping the page
            child: ClipPath(
              child: SAScaffold(
                isLoading: NetworkManager.instance.networkActivity,
                body: RefreshIndicator(
                  onRefresh: () async => currentUser.triggerReload(),
                  child: pudoList == null
                      ? const SizedBox()
                      : pudoList!.isEmpty
                          ? const NoPudosWidget()
                          : _buildPudos(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //MARK: Build widget accessories

  Widget _buildPudos() {
    return DeletableListView<PudoSummary>(
      hasScrollBar: true,
      title: 'I tuoi pudo:'.toUpperCase(),
      titleStyle: Theme.of(context).textTheme.headerTitle,
      itemBuilder: (PudoSummary pudo) => PudoMapCard(
        name: pudo.businessName,
        address: pudo.label ?? "",
        stars: (pudo.rating?.stars ?? 0).toInt(),
        image: pudo.pudoPicId,
        onTap: () => _openPudo(pudo),
        hasShadow: true,
      ),
      items: pudoList!,
      idGetter: (PudoSummary pudo) => pudo.pudoId!,
      onDelete: (PudoSummary pudo) => _deletePudo(pudo),
      alertDeleteText: "Sei sicuro di voler rimuovere questo pudo?\nSe continui non riceverai ulteriori notifiche per i pacchi non ancora consegnati",
    );
  }

  //MARK: Actions

  void _deletePudo(PudoSummary pudoProfile) {
    NetworkManager.instance.deletePudoFavorite(pudoProfile.pudoId.toString()).then((value) {
      if (value is List<PudoSummary>) {
        Provider.of<CurrentUser>(context, listen: false).triggerReload();
      } else {
        NetworkErrorHelper.helper(context, value);
      }
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  void _openPudo(PudoSummary pudoSummary) => NetworkManager.instance.getPudoDetails(pudoId: pudoSummary.pudoId.toString()).then((value) {
        if (value is PudoProfile) {
          Navigator.of(context).pushNamed(Routes.pudoDetail, arguments: value);
        } else {
          NetworkErrorHelper.helper(context, value);
        }
      }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));

  Future<void> _getPudos() {
    return NetworkManager.instance.getMyPudos().then((value) {
      if (value is List<PudoSummary>) {
        pudoList = value;
      } else {
        NetworkErrorHelper.helper(context, value);
      }
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }
}
