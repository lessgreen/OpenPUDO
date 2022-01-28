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

// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/view_models/insert_address_controller_viewmodel.dart';
import 'package:qui_green/widgets/address_field.dart';
import 'package:qui_green/resources/res.dart';

class InsertAddressController extends StatefulWidget {
  const InsertAddressController({Key? key}) : super(key: key);

  @override
  _InsertAddressControllerState createState() =>
      _InsertAddressControllerState();
}

class _InsertAddressControllerState extends State<InsertAddressController> {
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
    return MultiProvider(
        providers: [
          ChangeNotifierProxyProvider0<InsertAddressControllerViewModel?>(
              create: (context) => InsertAddressControllerViewModel(),
              update: (context, viewModel) => viewModel),
        ],
        child: Consumer<InsertAddressControllerViewModel?>(
            builder: (_, viewModel, __) {
          return KeyboardVisibilityBuilder(
              builder: (context, child, isKeyboardVisible) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                  leading: const SizedBox(),
                ),
                body: Column(
                  children: [
                    Center(
                      child: Text(
                        'Inserisci il tuo indirizzo',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
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
