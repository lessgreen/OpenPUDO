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
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/view_models/registration_complete_controller_viewmodel.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/pudo_card.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class RegistrationCompleteController extends StatefulWidget {
  const RegistrationCompleteController({Key? key, this.pudoDataModel, required this.canGoBack, required this.useCupertinoScaffold}) : super(key: key);
  final PudoProfile? pudoDataModel;
  final bool canGoBack;
  final bool useCupertinoScaffold;

  @override
  _RegistrationCompleteControllerState createState() => _RegistrationCompleteControllerState();
}

class _RegistrationCompleteControllerState extends State<RegistrationCompleteController> with ConnectionAware {
  void _showErrorDialog(BuildContext context, dynamic val) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), val);

  Widget _buildPageWithCupertinoScaffold(RegistrationCompleteControllerViewModel viewModel, bool isKeyboardVisible) {
    return SAScaffold(
      resizeToAvoidBottomInset: false,
      cupertinoBar: widget.useCupertinoScaffold
          ? CupertinoNavigationBarFix.build(
              context,
              middle: Text(
                'navBarTitle'.localized(context),
                style: Theme.of(context).textTheme.navBarTitle,
              ),
              leading: widget.canGoBack
                  ? CupertinoNavigationBarBackButton(
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : const SizedBox(),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: widget.canGoBack
            ? CupertinoNavigationBarBackButton(
                color: AppColors.primaryColorDark,
                onPressed: () => Navigator.of(context).pop(),
              )
            : const SizedBox(),
        centerTitle: true,
        title: Text(
          'navBarTitle'.localized(context),
          style: Theme.of(context).textTheme.navBarTitleDark,
        ),
      ),
      body: _buildBody(viewModel, isKeyboardVisible),
    );
  }

  Widget _buildBody(RegistrationCompleteControllerViewModel viewModel, bool isKeyboardVisible) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 100,
            left: -40,
            right: -40,
            child: Opacity(
              opacity: 0.2,
              child: SvgPicture.asset(ImageSrc.doneUserOnboarding),
            ),
          ),
          Column(
            children: [
              const SizedBox(
                height: Dimension.padding,
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                child: Text(
                  'mainLabel'.localized(context),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1Regular,
                ),
              ),
              (widget.pudoDataModel != null)
                  ? Padding(
                      padding: const EdgeInsets.only(top: Dimension.paddingL, left: Dimension.padding, right: Dimension.padding),
                      child: FutureBuilder(
                          future: NetworkManager.instance.getPudoDetails(pudoId: widget.pudoDataModel!.pudoId.toString()),
                          builder: (context, value) {
                            bool state = false;
                            if (value.hasData) {
                              if (value.data is PudoProfile) {
                                viewModel.pudoModel = value.data as PudoProfile;
                                state = true;
                              }
                            }
                            return AnimatedSwitcher(
                                child: state
                                    ? PudoCard(
                                        dataSource: value.data as PudoProfile,
                                        onTap: () {},
                                        showCustomizedAddress: true,
                                      )
                                    : PudoCard(
                                        dataSource: widget.pudoDataModel!,
                                        onTap: () {},
                                        showCustomizedAddress: false,
                                      ),
                                duration: const Duration(milliseconds: 150));
                          }),
                    )
                  : const SizedBox(),
              const SizedBox(height: Dimension.paddingL),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                child: Row(children: [
                  CupertinoSwitch(
                      trackColor: Colors.grey.shade200,
                      activeColor: AppColors.primaryColorDark,
                      value: viewModel.showNumber,
                      onChanged: (bool newValue) {
                        viewModel.updateShowNumberPreference(newValue);
                      }),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'allowContact'.localized(context),
                        style: Theme.of(context).textTheme.captionSwitch,
                      ),
                    ),
                  )
                ]),
              ),
              const Spacer(),
              if (widget.pudoDataModel != null)
                MainButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimension.padding,
                  ),
                  onPressed: () => viewModel.onInstructionsClick(context, widget.pudoDataModel),
                  text: 'showInstructions'.localized(context),
                ),
              const SizedBox(height: Dimension.padding),
              AnimatedCrossFade(
                crossFadeState: isKeyboardVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                secondChild: const SizedBox(),
                firstChild: MainButton(
                  onPressed: () => viewModel.onGoHomeClick(context),
                  text: 'goToHome'.localized(context),
                ),
                duration: const Duration(milliseconds: 150),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegistrationCompleteControllerViewModel(),
      child: Consumer<RegistrationCompleteControllerViewModel?>(
        builder: (_, viewModel, __) {
          viewModel?.showErrorDialog = (dynamic val) => _showErrorDialog(context, val);
          return KeyboardVisibilityBuilder(
            builder: (context, child, isKeyboardVisible) {
              if (widget.canGoBack) {
                return _buildPageWithCupertinoScaffold(viewModel!, isKeyboardVisible);
              }
              return WillPopScope(onWillPop: () async => false, child: _buildPageWithCupertinoScaffold(viewModel!, isKeyboardVisible));
            },
          );
        },
      ),
    );
  }
}
