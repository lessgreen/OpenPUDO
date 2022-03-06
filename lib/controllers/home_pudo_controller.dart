// ignore_for_file: invalid_use_of_protected_member

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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/table_view_cell.dart';

class HomePudoController extends StatefulWidget {
  const HomePudoController({Key? key}) : super(key: key);

  @override
  _HomePudoControllerState createState() => _HomePudoControllerState();
}

class _HomePudoControllerState extends State<HomePudoController> with ConnectionAware {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBarFix.build(
          context,
          middle: Text(
            'QuiGreen',
            style: Theme.of(context).textTheme.navBarTitle,
          ),
        ),
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: Dimension.paddingM,
            ),
            Padding(
              padding: const EdgeInsets.only(left: Dimension.padding),
              child: Text(
                "Azioni disponibili:",
                style: Theme.of(context).textTheme.headerTitle,
              ),
            ),
            TableViewCell(
              onTap: () => Navigator.of(context).pushNamed(Routes.packageReceived),
              fullWidth: true,
              showTopDivider: true,
              showTrailingChevron: true,
              title: "Ricevi un pacco",
              leading: SvgPicture.asset(
                ImageSrc.boxFillIcon,
                color: AppColors.cardColor,
                width: 36,
                height: 36,
              ),
            ),
            TableViewCell(
              onTap: () => Navigator.of(context).pushNamed(Routes.packageDelivered),
              fullWidth: true,
              showTrailingChevron: true,
              title: "Consegna un pacco",
              leading: SvgPicture.asset(
                ImageSrc.packageDeliveredLeadingIcon,
                color: AppColors.cardColor,
                fit: BoxFit.fitHeight,
                width: 36,
                height: 36,
              ),
            ),
            TableViewCell(
              onTap: () => Navigator.of(context).pushNamed(Routes.packagesListWithHistory),
              fullWidth: true,
              showTrailingChevron: true,
              title: "Pacchi in giacenza",
              leading: SvgPicture.asset(
                ImageSrc.boxFillIcon,
                color: AppColors.cardColor,
                width: 36,
                height: 36,
              ),
            )
          ],
        )),
      ),
    );
  }
}
