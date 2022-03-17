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
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/models/reward_option.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/view_models/pudo_profile_edit_controller_viewmodel.dart';
import 'package:qui_green/widgets/address_overlay_search.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/pudo_editable_image.dart';
import 'package:qui_green/widgets/reward_option_widget.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/widgets/text_field_button.dart';

class PudoProfileEditController extends StatefulWidget {
  const PudoProfileEditController({Key? key, required this.isOnHome, this.rewardOptions}) : super(key: key);
  final bool isOnHome;
  final List<RewardOption>? rewardOptions;

  @override
  _PudoProfileEditControllerState createState() => _PudoProfileEditControllerState();
}

class _PudoProfileEditControllerState extends State<PudoProfileEditController> with ConnectionAware {
  final keyButtons = GlobalKey();
  final keyText = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(builder: (context, currentUser, _) {
      return ChangeNotifierProvider(
          create: (context) => PudoProfileEditControllerViewModel(context, currentUser.pudoProfile!, widget.isOnHome, widget.rewardOptions),
          child: Consumer<PudoProfileEditControllerViewModel>(
            builder: (BuildContext context, viewModel, Widget? child) {
              return widget.isOnHome ? _buildForHome(currentUser, viewModel) : _buildForOnboarding(currentUser, viewModel);
            },
          ));
    });
  }

  Widget _buildForHome(CurrentUser currentUser, PudoProfileEditControllerViewModel viewModel) => CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBarFix.build(
        context,
        middle: Text(
          'navTitle'.localized(context),
          style: Theme.of(context).textTheme.navBarTitle,
        ),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: Dimension.paddingS),
          child: TextFieldButton(
            onPressed: () => viewModel.handleEdit(context, currentUser.pudoProfile!),
            text: (viewModel.editEnabled ? "saveButton" : 'editButton').localized(context),
            textColor: Colors.white,
          ),
        ),
      ),
      child: SafeArea(child: _buildBody(currentUser, viewModel)));

  Widget _buildForOnboarding(CurrentUser currentUser, PudoProfileEditControllerViewModel viewModel) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            backgroundColor: ThemeData.light().scaffoldBackgroundColor,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            leading: const SizedBox(),
            title: Text(
              currentUser.pudoProfile!.businessName,
              style: Theme.of(context).textTheme.navBarTitleDark,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: Dimension.paddingS),
                child: TextFieldButton(
                  onPressed: () => viewModel.handleEdit(context, currentUser.pudoProfile!),
                  text: (viewModel.editEnabled ? "saveButton" : 'editButton').localized(context),
                  textColor: AppColors.primaryColorDark,
                ),
              ),
            ]),
        body: SafeArea(
          child: Stack(children: [
            _buildBody(currentUser, viewModel),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(key: keyButtons, mainAxisSize: MainAxisSize.min, children: [
                IgnorePointer(
                  ignoring: true,
                  child: ShaderMask(
                      shaderCallback: (Rect rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Theme.of(context).backgroundColor, Colors.transparent, Colors.transparent, Colors.transparent],
                          stops: const [0, 0.5, 0.7, 1],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstOut,
                      child: Container(
                        color: Colors.white.withAlpha(225),
                        height: Dimension.paddingL,
                        width: double.infinity,
                      )),
                ),
                AnimatedCrossFade(
                    firstChild: MainButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimension.padding,
                      ),
                      onPressed: () => viewModel.goToInstructions(context, currentUser.pudoProfile!),
                      text: 'showInstructions'.localized(context),
                    ),
                    secondChild: const SizedBox(),
                    crossFadeState: viewModel.editEnabled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 100)),
                Container(
                  height: Dimension.padding,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                AnimatedCrossFade(
                    firstChild: MainButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimension.padding,
                      ),
                      onPressed: () => currentUser.refresh(),
                      text: 'goToHome'.localized(context),
                    ),
                    secondChild: const SizedBox(),
                    crossFadeState: viewModel.editEnabled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 100)),
              ]),
            )
          ]),
        ),
      );

  Widget _buildBody(CurrentUser currentUser, PudoProfileEditControllerViewModel viewModel) => SAScaffold(
        isLoading: NetworkManager.instance.networkActivity,
        body: ListView(children: [
          Container(
              padding: const EdgeInsets.only(bottom: Dimension.padding),
              alignment: Alignment.center,
              child: Column(children: [
                PudoEditableImage(picId: currentUser.pudoProfile?.pudoPicId, selectedImage: viewModel.image, editEnabled: viewModel.editEnabled, onTap: () => viewModel.pickFile(context)),
                _buildPudoDetail(currentUser, viewModel),
                const SizedBox(height: Dimension.padding),
                _buildEditable(
                    viewModel,
                    Padding(
                      padding: const EdgeInsets.only(bottom: Dimension.padding),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3 * 2,
                        height: 1,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox()),
                _buildEditable(
                    viewModel,
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info,
                            color: AppColors.primaryColorDark,
                          ),
                          const SizedBox(
                            width: Dimension.paddingS,
                          ),
                          Text(
                            'rewardDescriptionTitle'.localized(context),
                            style: Theme.of(context).textTheme.captionLightItalic,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox())
              ])),
          _buildEditable(
            viewModel,
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 3 * 2,
                child: Text(
                  '“${currentUser.pudoProfile?.rewardMessage ?? ""}”',
                  key: keyText,
                  style: Theme.of(context).textTheme.pudoRewardPolicy,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: Dimension.paddingL),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.dataSource.length,
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
          if (_checkIfOverlaps() && !viewModel.editEnabled)
            SizedBox(
              height: _getButtonsHeight(),
            )
        ]),
      );

  Widget _buildPudoDetail(CurrentUser currentUser, PudoProfileEditControllerViewModel viewModel) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Dimension.padding),
            _buildEditable(
                viewModel,
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(style: Theme.of(context).textTheme.headline6, children: [
                    TextSpan(text: currentUser.pudoProfile!.businessName),
                    WidgetSpan(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List<Widget>.generate(
                          5,
                          (index) => Icon(
                            Icons.star_rounded,
                            color: (index + 1 <= (currentUser.pudoProfile!.rating?.stars ?? 0)) ? Colors.yellow.shade700 : Colors.grey.shade200,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                CupertinoTextField(
                  controller: viewModel.businessNameController,
                  padding: const EdgeInsets.all(Dimension.padding),
                  placeholderStyle: const TextStyle(color: AppColors.colorGrey),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  onChanged: (newVal) => viewModel.name = newVal,
                )),
            const SizedBox(height: Dimension.paddingS),
            _buildEditable(
                viewModel,
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(text: '', style: Theme.of(context).textTheme.bodyText2, children: [
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primaryColorDark,
                      ),
                    ),
                    const WidgetSpan(
                      child: SizedBox(
                        width: Dimension.paddingS,
                      ),
                    ),
                    TextSpan(text: currentUser.pudoProfile!.address?.label ?? ""),
                  ]),
                ),
                Column(children: [
                  CupertinoTextField(
                    controller: viewModel.addressController,
                    onChanged: (newValue) => viewModel.onSearchChanged(newValue),
                    prefix: const Icon(Icons.location_on_rounded, color: AppColors.primaryColorDark, size: 23),
                    padding: const EdgeInsets.all(Dimension.padding),
                    placeholderStyle: const TextStyle(color: AppColors.colorGrey),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                  ),
                  AnimatedCrossFade(
                    firstChild: SizedBox(width: MediaQuery.of(context).size.width),
                    secondChild: Container(
                      decoration: const BoxDecoration(boxShadow: Shadows.baseShadow),
                      margin: const EdgeInsets.symmetric(vertical: Dimension.paddingS, horizontal: Dimension.paddingS),
                      child: AddressOverlaySearch(
                        borderRadius: BorderRadius.zero,
                        onTap: (GeoMarker marker) {
                          viewModel.address = viewModel.convertGeoMarker(marker);
                          viewModel.addressController.text = marker.address!.label ?? "";
                          viewModel.isOpenListAddress = false;
                        },
                        addresses: viewModel.addresses,
                      ),
                    ),
                    crossFadeState: viewModel.isOpenListAddress ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 150),
                  ),
                ])),
            const SizedBox(height: Dimension.paddingS),
            _buildEditable(
              viewModel,
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(text: '', style: Theme.of(context).textTheme.bodyText2, children: [
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: SvgPicture.asset(
                        ImageSrc.phoneIconFill,
                        color: AppColors.primaryColorDark,
                        width: 23,
                        height: 23,
                      )),
                  const WidgetSpan(
                    child: SizedBox(
                      width: Dimension.paddingS,
                    ),
                  ),
                  TextSpan(text: currentUser.pudoProfile!.publicPhoneNumber ?? ""),
                ]),
              ),
              CupertinoTextField(
                controller: viewModel.phoneController,
                prefix: SvgPicture.asset(
                  ImageSrc.phoneIconFill,
                  color: AppColors.primaryColorDark,
                  width: 23,
                  height: 23,
                ),
                padding: const EdgeInsets.all(Dimension.padding),
                placeholderStyle: const TextStyle(color: AppColors.colorGrey),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                autofocus: false,
                textInputAction: TextInputAction.done,
                onChanged: (newVal) => viewModel.phoneNumber = newVal,
              ),
            ),
          ],
        ),
      );

  Widget _buildEditable(PudoProfileEditControllerViewModel viewModel, Widget view, Widget edit) => AnimatedCrossFade(
        firstChild: view,
        secondChild: edit,
        crossFadeState: viewModel.editEnabled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 150),
      );

  bool _checkIfOverlaps() {
    if (keyButtons.currentContext != null && keyText.currentContext != null) {
      RenderBox? box1 = keyButtons.currentContext!.findRenderObject() as RenderBox?;
      RenderBox? box2 = keyText.currentContext!.findRenderObject() as RenderBox?;
      if (box1 != null && box2 != null) {
        final size1 = box1.size;
        final size2 = box2.size;
        final position1 = box1.localToGlobal(Offset.zero);
        final position2 = box2.localToGlobal(Offset.zero);
        return (position1.dx < position2.dx + size2.width && position1.dx + size1.width > position2.dx && position1.dy < position2.dy + size2.height && position1.dy + size1.height > position2.dy);
      }
    }
    return false;
  }

  double _getButtonsHeight() {
    if (keyButtons.currentContext != null) {
      RenderBox? box1 = keyButtons.currentContext!.findRenderObject() as RenderBox?;
      if (box1 != null) {
        final size1 = box1.size;
        return size1.height;
      }
    }
    return 0;
  }
}
