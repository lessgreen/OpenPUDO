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

// ignore_for_file: unused_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/pudo_map_card.dart';
import 'package:qui_green/resources/routes_enum.dart';

class HomePudoController extends StatefulWidget {
  const HomePudoController({Key? key}) : super(key: key);

  @override
  _HomePudoControllerState createState() => _HomePudoControllerState();
}

class _HomePudoControllerState extends State<HomePudoController> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.all(0),
        brightness: Brightness.dark,
        backgroundColor: AppColors.primaryColorDark,
        middle: Text(
          'I tuoi Pudo',
          style: Theme.of(context)
              .textTheme
              .headline6
              ?.copyWith(color: Colors.white),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Non hai ancora aggiunto un pudo per le tue consegne!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          MainButton(
              text: 'Vai',
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.userPosition))
        ],
      ),
    );
  }
}
