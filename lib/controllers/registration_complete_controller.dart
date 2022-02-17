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
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/view_models/registration_complete_controller_viewmodel.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/pudo_map_card.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class RegistrationCompleteController extends StatefulWidget {
  const RegistrationCompleteController({Key? key, this.pudoDataModel, required this.useCupertinoScaffold, required this.canGoBack}) : super(key: key);
  final PudoProfile? pudoDataModel;
  final bool useCupertinoScaffold;
  final bool canGoBack;

  @override
  _RegistrationCompleteControllerState createState() => _RegistrationCompleteControllerState();
}

class _RegistrationCompleteControllerState extends State<RegistrationCompleteController> with ConnectionAware {
  void _showErrorDialog(BuildContext context, dynamic val) => SAAlertDialog.displayAlertWithClose(context, "Error", val);

  Widget _buildPageWithCupertinoScaffold(RegistrationCompleteControllerViewModel viewModel, bool isKeyboardVisible) => CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        navigationBar: CupertinoNavigationBar(
            padding: const EdgeInsetsDirectional.all(0),
            brightness: Brightness.dark,
            backgroundColor: AppColors.primaryColorDark,
            middle: Text(
              'Fatto!',
              style: Theme.of(context).textTheme.navBarTitle,
            ),
            leading: widget.canGoBack
                ? CupertinoNavigationBarBackButton(
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null),
        child: _buildBody(viewModel, isKeyboardVisible),
      );

  Widget _buildPageWithBaseScaffold(RegistrationCompleteControllerViewModel viewModel, bool isKeyboardVisible) => Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: false,
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
        body: _buildBody(viewModel, isKeyboardVisible),
      );

  Widget _buildBody(RegistrationCompleteControllerViewModel viewModel, bool isKeyboardVisible) => SAScaffold(
        isLoading: NetworkManager.instance.networkActivity,
        body: SafeArea(
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
                  if (!widget.useCupertinoScaffold)
                    Center(
                      child: Text(
                        'Fatto!',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  if (widget.useCupertinoScaffold)
                    const SizedBox(
                      height: Dimension.padding,
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                    child: Text(
                      'Adesso potrai usare questo indirizzo per farti inviare i tuoi pacchi in totale comodità!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w400),
                    ),
                  ),
                  (widget.pudoDataModel != null)
                      ? Padding(
                          padding: const EdgeInsets.only(top: Dimension.paddingL, left: Dimension.padding, right: Dimension.padding),
                          child: PudoMapCard(
                            name: widget.pudoDataModel?.businessName ?? "",
                            address: widget.pudoDataModel?.address?.label ?? "",
                            stars: widget.pudoDataModel?.rating?.stars ?? 0,
                            onTap: () {},
                            image: widget.pudoDataModel?.pudoPicId,
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: Dimension.paddingL),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                    child: Row(
                      children: [
                        CupertinoSwitch(
                          trackColor: Colors.grey.shade200,
                          activeColor: AppColors.primaryColorDark,
                          value: viewModel.showNumber,
                          onChanged: (bool newValue) {
                            viewModel.updateShowNumberPreference(newValue);
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Permetti ai pudo di contattarmi al mio numero telefonico in caso di comunicazioni inerenti i miei pacchi.',
                              style: Theme.of(context).textTheme.caption?.copyWith(fontStyle: FontStyle.italic, height: 1.5, letterSpacing: 0),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (widget.pudoDataModel != null)
                    MainButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimension.padding,
                      ),
                      onPressed: () => viewModel.onInstructionsClick(context, widget.pudoDataModel),
                      text: 'Vedi le istruzioni',
                    ),
                  const SizedBox(height: Dimension.padding),
                  AnimatedCrossFade(
                    crossFadeState: isKeyboardVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    secondChild: const SizedBox(),
                    firstChild: MainButton(
                      onPressed: () => viewModel.onGoHomeClick(context),
                      text: 'Vai alla home',
                    ),
                    duration: const Duration(milliseconds: 150),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

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
                return widget.useCupertinoScaffold ? _buildPageWithCupertinoScaffold(viewModel!, isKeyboardVisible) : _buildPageWithBaseScaffold(viewModel!, isKeyboardVisible);
              }
              return WillPopScope(
                onWillPop: () async => false,
                child: widget.useCupertinoScaffold ? _buildPageWithCupertinoScaffold(viewModel!, isKeyboardVisible) : _buildPageWithBaseScaffold(viewModel!, isKeyboardVisible),
              );
            },
          );
        },
      ),
    );
  }
}
