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
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/view_models/insert_address_controller_viewmodel.dart';
import 'package:qui_green/widgets/address_field.dart';
import 'package:qui_green/widgets/main_button.dart';

class HomeInsertAddressController extends StatefulWidget {
  const HomeInsertAddressController({Key? key}) : super(key: key);

  @override
  _HomeInsertAddressControllerState createState() =>
      _HomeInsertAddressControllerState();
}

class _HomeInsertAddressControllerState
    extends State<HomeInsertAddressController> {
  final FocusNode _address = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(_address);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => InsertAddressControllerViewModel(),
        child: Consumer<InsertAddressControllerViewModel?>(
            builder: (_, viewModel, __) {
          return KeyboardVisibilityBuilder(
              builder: (context, child, isKeyboardVisible) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                padding: const EdgeInsetsDirectional.all(0),
                brightness: Brightness.dark,
                backgroundColor: AppColors.primaryColorDark,
                middle: Text(
                  'Inserisci il tuo indirizzo',
                  style: AdditionalTextStyles.navBarStyle(context),
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
                    const SizedBox(height: Dimension.padding),
                    // Center(
                    //   child: Text(
                    //     'Inserisci il tuo indirizzo',
                    //     style: Theme.of(context).textTheme.headline6,
                    //   ),
                    // ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: AddressField(
                          viewModel: viewModel!,
                          node: _address,
                        )),
                    const Spacer(),
                    SvgPicture.asset(ImageSrc.userPositionArt,
                        semanticsLabel: 'Art Background'),
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
                  ],
                ),
              ),
            );
          });
        }));
  }
}
