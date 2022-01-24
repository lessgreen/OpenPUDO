//
//   user_position_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Wed Jan 05 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/controllers/exchange/viewmodel/exchange_controller_viewmodel.dart';
import 'package:qui_green/controllers/exchange/widgets/exchange_option_tile.dart';
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
          ChangeNotifierProxyProvider0<ExchangeControllerViewModel?>(
              create: (context) => ExchangeControllerViewModel(),
              update: (context, viewModel) => viewModel),
        ],
        child:
            Consumer<ExchangeControllerViewModel?>(builder: (_, viewModel, __) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent));
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
                        'Desideri qualcosa in cambio?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    const SizedBox(
                      height: Dimension.paddingM,
                    ),
                    Container(
                        padding: const EdgeInsets.only(
                            left: Dimension.padding, right: Dimension.padding),
                        child: const Text(
                          'Puoi decidere di fornire il servizio QuiGreen in maniera completamente gratuita oppure puoi essere pagato in uno dei seguenti modi:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey),
                        )),
                    const SizedBox(height: Dimension.padding),
                    const Divider(color: Colors.grey),
                    Expanded(
                        child: ListView.builder(
                      itemCount: viewModel?.options.length,
                      itemBuilder: (context, index) => ExchangeOptionTile(
                        isNonMultipleActive:
                            viewModel?.isANonMultipleActive(index) ?? false,
                        value: viewModel?.optionValues[index].value ?? false,
                        onSelect: (newVal) =>
                            viewModel?.onValueChange(index, newVal),
                        model: viewModel?.options[index] ??
                            ExchangeOptionModel(
                                hintText: "",
                                hasField: false,
                                acceptMultiple: true,
                                name: "",
                                icon: Icons.crop),
                        onTextChange: (newVal) =>
                            viewModel?.onTextChange(index, newVal),
                      ),
                    )),
                    AnimatedCrossFade(
                      crossFadeState: isKeyboardVisible
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
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
