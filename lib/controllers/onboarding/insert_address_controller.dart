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
import 'package:qui_green/commons/ui/optimized_cupertino_navigation_bar.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/view_models/insert_address_controller_viewmodel.dart';
import 'package:qui_green/widgets/address_field.dart';
import 'package:qui_green/widgets/main_button.dart';

class InsertAddressController extends StatefulWidget {
  const InsertAddressController({Key? key, required this.useCupertinoScaffold}) : super(key: key);
  final bool useCupertinoScaffold;

  @override
  _InsertAddressControllerState createState() => _InsertAddressControllerState();
}

class _InsertAddressControllerState extends State<InsertAddressController> with ConnectionAware {
  final FocusNode _address = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(_address);
    });
  }

  Widget _buildPageWithCupertinoScaffold(InsertAddressControllerViewModel viewModel, bool isKeyboardVisible) => CupertinoPageScaffold(
      navigationBar: OptimizedCupertinoNavigationBar.build(
        context,
        middle: Text(
          'Inserisci il tuo indirizzo',
          style: Theme.of(context).textTheme.navBarTitle,
        ),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: _buildBody(viewModel, isKeyboardVisible));

  Widget _buildPageWithBaseScaffold(InsertAddressControllerViewModel viewModel, bool isKeyboardVisible) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: CupertinoNavigationBarBackButton(
            color: AppColors.primaryColorDark,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _buildBody(viewModel, isKeyboardVisible),
      );

  Widget _buildBody(InsertAddressControllerViewModel viewModel, bool isKeyboardVisible) => Stack(children: [
        SvgPicture.asset(ImageSrc.userPositionArt, semanticsLabel: 'Art Background'),
        Column(children: [
          if (!widget.useCupertinoScaffold)
            Center(
              child: Text(
                'Inserisci il tuo indirizzo',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          if (widget.useCupertinoScaffold) const SizedBox(height: Dimension.padding),
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AddressField(
                viewModel: viewModel,
                node: _address,
              )),
          const Spacer(),
          const SizedBox(height: Dimension.padding),
          AnimatedCrossFade(
            crossFadeState: isKeyboardVisible
                ? CrossFadeState.showSecond
                : viewModel.hasSelected
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
            secondChild: const SizedBox(),
            firstChild: MainButton(
              onPressed: () => viewModel.onSendClick(context),
              text: 'Invia',
            ),
            duration: const Duration(milliseconds: 150),
          ),
        ]),
      ]);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => InsertAddressControllerViewModel(),
        child: Consumer<InsertAddressControllerViewModel?>(builder: (_, viewModel, __) {
          return KeyboardVisibilityBuilder(builder: (context, child, isKeyboardVisible) {
            return widget.useCupertinoScaffold ? _buildPageWithCupertinoScaffold(viewModel!, isKeyboardVisible) : _buildPageWithBaseScaffold(viewModel!, isKeyboardVisible);
          });
        }));
  }
}
