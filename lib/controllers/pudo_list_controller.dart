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
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/pudo_summary.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/pudo_card.dart';
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
    getPudos();
  }

  List<PudoSummary>? pudoList;

  void deletePudo(PudoSummary pudoProfile) {
    NetworkManager.instance.deletePudoFavorite(pudoProfile.pudoId.toString()).then((value) {
      if (value is List<PudoSummary>) {
        setState(() {
          pudoList = value;
        });
      } else {
        SAAlertDialog.displayAlertWithClose(context, "Error", "Qualcosa è andato storto");
      }
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  Future<void> getPudos() async {
    NetworkManager.instance.getMyPudos().then((value) {
      if (value is List<PudoSummary>) {
        setState(() {
          pudoList = value;
        });
      } else {
        SAAlertDialog.displayAlertWithClose(context, "Error", "Qualcosa è andato storto");
      }
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  Widget _buildEmptyPudos() => Column(
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
      );

  Widget _buildPudos() => RefreshIndicator(
        onRefresh: getPudos,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: Dimension.padding, top: Dimension.padding),
              child: Text(
                'I tuoi pudo:',
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pudoList!.length,
                itemBuilder: (BuildContext context, int index) {
                  return PudoCard(
                      maxWidth: MediaQuery.of(context).size.width / 3,
                      onDelete: () => deletePudo(pudoList![index]),
                      pudo: pudoList![index],
                      onTap: () {
                        NetworkManager.instance.getPudoDetails(pudoId: pudoList![index].pudoId.toString()).then((value) {
                          if (value is PudoProfile) {
                            Navigator.of(context).pushNamed(Routes.pudoDetail, arguments: value);
                          } else {
                            SAAlertDialog.displayAlertWithClose(context, "Error", "Qualcosa è andato storto");
                          }
                        }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
                      });
                })
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
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
                shouldReload: NetworkManager.instance.shouldReload,
                onReload: getPudos,
                isLoading: NetworkManager.instance.networkActivity,
                body: pudoList == null
                    ? const SizedBox()
                    : pudoList!.isEmpty
                        ? _buildEmptyPudos()
                        : _buildPudos()),
          )),
    );
  }
}
