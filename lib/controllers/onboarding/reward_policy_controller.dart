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
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/registration_pudo_model.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/view_models/reward_policy_controller_viewmodel.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/reward_option_widget.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class RewardPolicyController extends StatefulWidget {
  const RewardPolicyController({Key? key, required this.pudoRegistrationModel}) : super(key: key);
  final RegistrationPudoModel pudoRegistrationModel;

  @override
  _RewardPolicyControllerState createState() => _RewardPolicyControllerState();
}

class _RewardPolicyControllerState extends State<RewardPolicyController> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RewardPolicyControllerViewModel(context),
      child: Consumer<RewardPolicyControllerViewModel?>(
        builder: (_, viewModel, __) {
          return KeyboardVisibilityBuilder(builder: (context, child, isKeyboardVisible) {
            return WillPopScope(
              onWillPop: () async => false,
              child: SAScaffold(
                isLoading: NetworkManager.instance.networkActivity,
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                  leading: const SizedBox(),
                  toolbarHeight: 0,
                ),
                body: Column(
                  children: [
                    const SizedBox(
                      height: Dimension.paddingM,
                    ),
                    Center(
                      child: Text(
                        'rewardWanted'.localized(context),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    const SizedBox(
                      height: Dimension.padding,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                        child: Text(
                          'hintReward'.localized(context),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey,
                          ),
                        )),
                    const SizedBox(
                      height: Dimension.paddingM,
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 1,
                    ),
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (Rect rect) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Theme.of(context).backgroundColor, Colors.transparent, Colors.transparent, Theme.of(context).backgroundColor],
                            stops: const [0.0, 0.02, 0.9, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstOut,
                        child: ListView.builder(
                          itemCount: viewModel?.dataSource.length,
                          itemBuilder: (context, index) {
                            return RewardOptionWidget(
                              index: index,
                              viewModel: viewModel,
                              hasTopPadding: index == 0,
                            );
                          },
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      crossFadeState: isKeyboardVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      secondChild: SizedBox(
                          height: 48,
                          child: Container(
                            color: Theme.of(context).cardColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  MaterialButton(
                                    onPressed: () {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    },
                                    child: Text(
                                      'doneButton'.localized(context),
                                      style: const TextStyle(color: AppColors.primaryColorDark),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),
                      firstChild: MainButton(
                        enabled: viewModel!.mandatoryFulfilled,
                        onPressed: () => viewModel.onSendClick(context, widget.pudoRegistrationModel),
                        text: 'nextButton'.localized(context),
                      ),
                      duration: const Duration(milliseconds: 150),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
