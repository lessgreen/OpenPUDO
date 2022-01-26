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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/widgets/exchange_option_tile.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/view_models/exchange_controller_viewmodel.dart';
import 'package:qui_green/models/exhange_option_model.dart';
import 'package:qui_green/resources/res.dart';

class ExchangeController extends StatefulWidget {
  const ExchangeController({Key? key}) : super(key: key);

  @override
  _ExchangeControllerState createState() => _ExchangeControllerState();
}

class _ExchangeControllerState extends State<ExchangeController> {
  bool checkAssociati = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProxyProvider0<ExchangeControllerViewModel?>(create: (context) => ExchangeControllerViewModel(), update: (context, viewModel) => viewModel),
        ],
        child: Consumer<ExchangeControllerViewModel?>(builder: (_, viewModel, __) {
          return KeyboardVisibilityBuilder(builder: (context, child, isKeyboardVisible) {
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
                        'Desideri qualcosa in cambio?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    const SizedBox(
                      height: Dimension.paddingM,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                        child: const Text(
                          'Puoi decidere di fornire il servizio QuiGreen in maniera completamente gratuita oppure puoi essere pagato in uno dei seguenti modi:',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey),
                        )),
                    const SizedBox(height: Dimension.padding),
                    const Divider(color: Colors.grey),
                    Expanded(
                        child: ListView.builder(
                      itemCount: viewModel?.options.length,
                      itemBuilder: (context, index) => ExchangeOptionTile(
                        isNonMultipleActive: viewModel?.isANonMultipleActive(index) ?? false,
                        value: viewModel?.optionValues[index].value ?? false,
                        onSelect: (newVal) => viewModel?.onValueChange(index, newVal),
                        model: viewModel?.options[index] ?? ExchangeOptionModel(hintText: "", hasField: false, acceptMultiple: true, name: "", icon: Icons.crop),
                        onTextChange: (newVal) => viewModel?.onTextChange(index, newVal),
                      ),
                    )),
                    AnimatedCrossFade(
                      crossFadeState: isKeyboardVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      secondChild: const SizedBox(),
                      firstChild: MainButton(
                        onPressed: () => viewModel!.onSendClick(context),
                        text: 'Avanti',
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
