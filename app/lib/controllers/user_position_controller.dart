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
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/view_models/user_position_controller_viewmodel.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class UserPositionController extends StatefulWidget {
  const UserPositionController({Key? key, required this.canGoBack}) : super(key: key);
  final bool canGoBack;

  @override
  State<UserPositionController> createState() => _UserPositionControllerState();
}

class _UserPositionControllerState extends State<UserPositionController> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserPositionControllerViewModel(),
      child: Consumer<UserPositionControllerViewModel?>(
        builder: (_, viewModel, __) {
          if (widget.canGoBack) {
            return _buildPageWithBaseScaffold(viewModel!);
          }
          return WillPopScope(
            onWillPop: () async => false,
            child: _buildPageWithBaseScaffold(viewModel!),
          );
        },
      ),
    );
  }

  //MARK: Build widget accessories

  Widget _buildPageWithBaseScaffold(UserPositionControllerViewModel viewModel) {
    return SAScaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: widget.canGoBack
            ? CupertinoNavigationBarBackButton(
                color: AppColors.primaryColorDark,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(UserPositionControllerViewModel viewModel) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    ImageSrc.userPositionArt,
                    semanticsLabel: 'Art Background',
                    width: MediaQuery.of(context).size.width,
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'navBarTitle'.localized(context),
                style: Theme.of(context).textTheme.headline6,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Center(
                  child: Text(
                    'mainLabel'.localized(context),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
              const Spacer(),
              MainButton(
                padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                onPressed: () async {
                  viewModel.tryGetUserLocation().then((value) {
                    if (value != null) {
                      viewModel.onMapClick(context);
                    }
                  });
                },
                text: 'allowGPSButton'.localized(context),
              ),
              const SizedBox(height: Dimension.padding),
              MainButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimension.padding,
                ),
                onPressed: () => viewModel.onAddAddressClick(context),
                text: 'chooseAddressButton'.localized(context),
              ),
              const SizedBox(height: Dimension.paddingL)
            ],
          ),
        ],
      ),
    );
  }
}
