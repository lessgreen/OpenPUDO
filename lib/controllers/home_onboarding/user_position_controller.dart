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
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/view_models/user_position_controller_viewmodel.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/resources/res.dart';

class HomeUserPositionController extends StatefulWidget {
  const HomeUserPositionController({Key? key}) : super(key: key);

  @override
  _HomeUserPositionControllerState createState() =>
      _HomeUserPositionControllerState();
}

class _HomeUserPositionControllerState
    extends State<HomeUserPositionController> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => UserPositionControllerViewModel(),
        child: Consumer<UserPositionControllerViewModel?>(
            builder: (_, viewModel, __) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              padding: const EdgeInsetsDirectional.all(0),
              brightness: Brightness.dark,
              backgroundColor: AppColors.primaryColorDark,
              middle: Text(
                '',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: Colors.white),
              ),
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Vediamo dove ti trovi',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Center(
                      child: Text(
                        'Per poterti fornire informazioni rilevanti\nabbiamo bisogno di accedere alla tua posizione.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SvgPicture.asset(ImageSrc.userPositionArt,
                      semanticsLabel: 'Art Background'),
                  const Spacer(),
                  MainButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimension.padding),
                    onPressed: () async {
                      viewModel?.tryGetUserLocation().then((value) {
                        if (value != null) {
                          viewModel.onMapClick(context);
                        }
                      });
                    },
                    text: 'Ok, grazie!',
                  ),
                  const SizedBox(height: Dimension.padding),
                  MainButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimension.padding,
                    ),
                    onPressed: () => viewModel?.onAddAddressClick(context),
                    text: 'Inserisci indirizzo',
                  ),
                  const SizedBox(height: Dimension.paddingL)
                ],
              ),
            ),
          );
        }));
  }
}
