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
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/pudo_summary.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/deleteble_listview.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/pudo_map_card.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class PudoListController extends StatefulWidget {
  const PudoListController({Key? key}) : super(key: key);

  @override
  _PudoListControllerState createState() => _PudoListControllerState();
}

class _PudoListControllerState extends State<PudoListController> {
  @override
  void initState() {
    super.initState();
  }

  List<PudoSummary>? pudoList;

  void deletePudo(PudoSummary pudoProfile) {
    NetworkManager.instance.deletePudoFavorite(pudoProfile.pudoId.toString()).then((value) {
      if (value is List<PudoSummary>) {
        Provider.of<CurrentUser>(context, listen: false).triggerReload();
      } else {
        SAAlertDialog.displayAlertWithClose(context, "Error", "Qualcosa è andato storto");
      }
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  void openPudo(PudoSummary pudoSummary) => NetworkManager.instance.getPudoDetails(pudoId: pudoSummary.pudoId.toString()).then((value) {
        if (value is PudoProfile) {
          Navigator.of(context).pushNamed(Routes.pudoDetail, arguments: value);
        } else {
          SAAlertDialog.displayAlertWithClose(context, "Error", "Qualcosa è andato storto");
        }
      }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));

  Future<void> getPudos() {
    return NetworkManager.instance.getMyPudos().then((value) {
      if (value is List<PudoSummary>) {
        pudoList = value;
      } else {
        SAAlertDialog.displayAlertWithClose(context, "Error", "Qualcosa è andato storto");
      }
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  Widget _buildEmptyPudos() => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Non hai ancora aggiunto un pudo per le tue consegne!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(
                  height: Dimension.padding,
                ),
                MainButton(text: 'Vai', onPressed: () => Navigator.of(context).pushNamed(Routes.userPosition))
              ],
            ),
          ),
        ),
      );

  Widget _buildPudos() => DeletableListView<PudoSummary>(
      title: 'I tuoi pudo:',
      itemBuilder: (PudoSummary pudo) => PudoMapCard(
            name: pudo.businessName,
            address: pudo.label ?? "",
            stars: (pudo.rating?.stars ?? 0).toInt(),
            image: pudo.pudoPicId,
            onTap: () => openPudo(pudo),
            hasShadow: true,
          ),
      items: pudoList!,
      idGetter: (PudoSummary pudo) => pudo.pudoId!,
      onDelete: (PudoSummary pudo) => deletePudo(pudo),
      alertDeleteText: "Sei sicuro di voler rimuovere questo pudo?\nSe continui non riceverai ulteriori notifiche per i pacchi non ancora consegnati");

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (context, currentUser, _) => FutureBuilder<void>(
        future: getPudos(),
        builder: (context, snapshot) => Material(
          child: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                padding: const EdgeInsetsDirectional.all(0),
                brightness: Brightness.dark,
                backgroundColor: AppColors.primaryColorDark,
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
                              ? _buildEmptyPudos()
                              : _buildPudos(),
                    )),
              )),
        ),
      ),
    );
  }
}
