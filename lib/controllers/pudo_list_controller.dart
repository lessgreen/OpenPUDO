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
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/widgets/pudo_map_card.dart';
import 'package:qui_green/resources/res.dart';

class PudoListController extends StatefulWidget {
  const PudoListController({Key? key}) : super(key: key);

  @override
  _PudoListControllerState createState() => _PudoListControllerState();
}

class _PudoListControllerState extends State<PudoListController> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.all(0),
          brightness: Brightness.dark,
          backgroundColor: AppColors.primaryColorDark,
          middle: Text('Il tuoi pudo', style: AdditionalTextStyles.navBarStyle(context)),
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: Dimension.padding,
                top: Dimension.padding,
              ),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'I tuoi pudo:',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
              child: PudoMapCard(
                name: "Bar - La pinta",
                address: "Via ippolito, 8",
                stars: 3,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
