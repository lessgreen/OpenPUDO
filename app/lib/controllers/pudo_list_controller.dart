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

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/commons/utilities/network_error_helper.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/pudo_summary.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/deleteble_listview.dart';
import 'package:qui_green/widgets/no_pudos_widget.dart';
import 'package:qui_green/widgets/pudo_card.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class PudoListController extends StatefulWidget {
  final bool isRootController;

  const PudoListController({
    Key? key,
    this.isRootController = false,
  }) : super(key: key);

  @override
  State<PudoListController> createState() => _PudoListControllerState();
}

class _PudoListControllerState extends State<PudoListController> {
  List<PudoSummary>? dataSource;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (context, currentUser, _) => FutureBuilder<void>(
        future: _getPudos(),
        builder: (context, snapshot) {
          return SAScaffold(
            isLoading: NetworkManager.instance.networkActivity,
            cupertinoBar: CupertinoNavigationBarFix.build(
              context,
              middle: Text(
                'navTitle'.localized(context),
                style: Theme.of(context).textTheme.navBarTitle,
              ),
              leading: widget.isRootController
                  ? null
                  : CupertinoNavigationBarBackButton(
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
            ),
            body: RefreshIndicator(
              onRefresh: () async => currentUser.triggerReload(),
              child: dataSource == null
                  ? const SizedBox()
                  : dataSource!.isEmpty
                      ? const NoPudosWidget()
                      : _buildPudos(),
            ),
          );
        },
      ),
    );
  }

  //MARK: Build widget accessories

  Widget _buildPudos() {
    return DeletableListView<PudoSummary>(
      borderRadius: BorderRadius.circular(Dimension.borderRadiusS),
      hasScrollBar: true,
      items: dataSource ?? [],
      itemBuilder: (PudoSummary pudo) {
        return PudoCard(
          dataSource: pudo,
          hasShadow: true,
          showCustomizedAddress: true,
          onTap: () => _openPudo(pudo),
          onLongPress: () {
            _openModal(pudo.customizedAddress);
          },
        );
      },
      idGetter: (PudoSummary pudo) => pudo.pudoId,
      onDelete: (PudoSummary pudo) => _deletePudo(pudo),
      alertDeleteText: 'deletePudoWarning'.localized(context),
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
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError));
  }

  void _openPudo(PudoSummary pudoSummary) => NetworkManager.instance.getPudoDetails(pudoId: pudoSummary.pudoId.toString()).then((value) {
        if (value is PudoProfile) {
          Navigator.of(context).pushNamed(Routes.pudoDetail, arguments: value);
        } else {
          NetworkErrorHelper.helper(context, value);
        }
      }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError));

  Future<void> _getPudos() {
    return NetworkManager.instance.getMyPudos().then((value) {
      if (value is List<PudoSummary>) {
        dataSource = value;
      } else {
        NetworkErrorHelper.helper(context, value);
      }
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError));
  }

  void _openModal(String? address) {
    if (address == null) {
      return;
    }
    SAAlertDialog.displayModalWithButtons(
      context,
      'chooseAction'.localized(context, 'general'),
      [
        CupertinoActionSheetAction(
          child: Text('copyAddressToClipboard'.localized(context)),
          onPressed: () {
            FlutterClipboard.copy(address);
          },
        ),
      ],
    );
  }
}
