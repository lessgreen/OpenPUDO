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
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/view_models/user_position_controller_viewmodel.dart';
import 'package:qui_green/widgets/main_button.dart';

class UserPositionController extends StatefulWidget {
  const UserPositionController({Key? key, required this.canGoBack, required this.useCupertinoScaffold}) : super(key: key);
  final bool canGoBack;
  final bool useCupertinoScaffold;

  @override
  _UserPositionControllerState createState() => _UserPositionControllerState();
}

class _UserPositionControllerState extends State<UserPositionController> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserPositionControllerViewModel(),
      child: Consumer<UserPositionControllerViewModel?>(
        builder: (_, viewModel, __) {
          if (widget.canGoBack) {
            return widget.useCupertinoScaffold ? _buildPageWithCupertinoScaffold(viewModel!) : _buildPageWithBaseScaffold(viewModel!);
          }
          return WillPopScope(
            onWillPop: () async => false,
            child: widget.useCupertinoScaffold ? _buildPageWithCupertinoScaffold(viewModel!) : _buildPageWithBaseScaffold(viewModel!),
          );
        },
      ),
    );
  }

  //MARK: Build widget accessories

  Widget _buildPageWithCupertinoScaffold(UserPositionControllerViewModel viewModel) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBarFix.build(
        context,
        leading: widget.canGoBack
            ? CupertinoNavigationBarBackButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              )
            : const SizedBox(),
        middle: Text(
          "Vediamo dove ti trovi",
          style: Theme.of(context).textTheme.navBarTitle,
          maxLines: 1,
        ),
      ),
      child: _buildBody(viewModel),
    );
  }

  Widget _buildPageWithBaseScaffold(UserPositionControllerViewModel viewModel) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: ThemeData.light().scaffoldBackgroundColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: widget.canGoBack
            ? CupertinoNavigationBarBackButton(
                color: AppColors.primaryColorDark,
                onPressed: () => Navigator.of(context).pop(),
              )
            : const SizedBox(),
      ),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(UserPositionControllerViewModel viewModel) {
    return SafeArea(
      child: Stack(
        children: [
          SvgPicture.asset(ImageSrc.userPositionArt, semanticsLabel: 'Art Background'),
          Column(
            children: [
              if (!widget.useCupertinoScaffold)
                Center(
                  child: Text(
                    'Vediamo dove ti trovi',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              if (widget.useCupertinoScaffold) const SizedBox(height: Dimension.padding),
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
              MainButton(
                padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                onPressed: () async {
                  viewModel.tryGetUserLocation().then((value) {
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
                onPressed: () => viewModel.onAddAddressClick(context),
                text: 'Inserisci indirizzo',
              ),
              const SizedBox(height: Dimension.paddingL)
            ],
          ),
        ],
      ),
    );
  }
}
