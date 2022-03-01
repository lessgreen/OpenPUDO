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
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/models/registration_pudo_model.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/view_models/pudo_registration_preview_controller_viewmodel.dart';
import 'package:qui_green/widgets/address_overlay_search.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/pudo_editable_image.dart';

class PudoRegistrationPreviewController extends StatefulWidget {
  const PudoRegistrationPreviewController({Key? key, required this.dataModel}) : super(key: key);
  final RegistrationPudoModel dataModel;

  @override
  _PudoRegistrationPreviewControllerState createState() => _PudoRegistrationPreviewControllerState();
}

class _PudoRegistrationPreviewControllerState extends State<PudoRegistrationPreviewController> with ConnectionAware {
  double bodyHeight = 0;
  double listHeight = 0;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildEditable(PudoRegistrationPreviewControllerViewModel viewModel, Widget view, Widget edit) =>
      AnimatedCrossFade(firstChild: view, secondChild: edit, crossFadeState: viewModel.editEnabled ? CrossFadeState.showSecond : CrossFadeState.showFirst, duration: const Duration(milliseconds: 150));

  Widget _buildPudoDetail(PudoRegistrationPreviewControllerViewModel viewModel) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: Dimension.padding),
          _buildEditable(
              viewModel,
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(style: Theme.of(context).textTheme.headline6, children: [
                  TextSpan(text: viewModel.businessNameController.text),
                ]),
              ),
              CupertinoTextField(
                controller: viewModel.businessNameController,
                padding: const EdgeInsets.all(Dimension.padding),
                placeholderStyle: const TextStyle(color: AppColors.colorGrey),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                autofocus: false,
                textInputAction: TextInputAction.done,
              )),
          const SizedBox(height: Dimension.paddingS),
          _buildEditable(
              viewModel,
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: '',
                  style: Theme.of(context).textTheme.bodyText2,
                  children: [
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
                    TextSpan(text: viewModel.addressController.text),
                  ],
                ),
              ),
              Column(
                children: [
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
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimension.borderRadiusS), border: Border.all(color: Colors.black)),
                      margin: const EdgeInsets.symmetric(vertical: Dimension.paddingS),
                      child: AddressOverlaySearch(
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
                ],
              )),
          const SizedBox(height: Dimension.paddingS),
          _buildEditable(
              viewModel,
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: '',
                  style: Theme.of(context).textTheme.bodyText2,
                  children: [
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
                    TextSpan(text: viewModel.phoneController.text),
                  ],
                ),
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
              )),
        ]),
      );

  Widget _buildBody(CurrentUser currentUser, PudoRegistrationPreviewControllerViewModel viewModel) => ListView(
        controller: controller,
        shrinkWrap: true,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: Dimension.padding),
            alignment: Alignment.center,
            child: Column(
              children: [
                PudoEditableImage(picId: currentUser.pudoProfile?.pudoPicId, selectedImage: viewModel.image, editEnabled: viewModel.editEnabled, onTap: viewModel.pickFile),
                _buildPudoDetail(viewModel),
                const SizedBox(height: Dimension.padding),
                Container(
                  width: MediaQuery.of(context).size.width / 3 * 2,
                  height: 1,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: Dimension.padding),
                Row(
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
                      'Per utilizzare QuiGreen in questo locale è richiesto:',
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3 * 2,
                  child: Text(
                    '“${currentUser.pudoProfile?.rewardMessage ?? ""}”',
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          height: 2,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (controller.positions.isNotEmpty && !viewModel.editEnabled)
                  if (controller.position.maxScrollExtent > 0)
                    const SizedBox(
                      height: 150,
                    )
              ],
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PudoRegistrationPreviewControllerViewModel(widget.dataModel),
      child: Consumer2<CurrentUser, PudoRegistrationPreviewControllerViewModel>(builder: (BuildContext context, currentUser, viewModel, Widget? child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: ThemeData.light().scaffoldBackgroundColor,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            leading: const SizedBox(),
            title: Text(
              viewModel.businessNameController.text,
              style: Theme.of(context).textTheme.navBarTitleDark,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            centerTitle: true,
            actions: const [
              /*Padding(
                    padding: const EdgeInsets.only(right: Dimension.paddingS),
                    child: TextFieldButton(
                      onPressed: () => viewModel.handleEdit(),
                      text: viewModel.editEnabled ? "Salva" : 'Modifica',
                      textColor: AppColors.primaryColorDark,
                    ),
                  ),*/
            ],
          ),
          body: SafeArea(
            child: Stack(children: [
              LayoutBuilder(builder: (context, constraints) {
                bodyHeight = constraints.maxHeight;
                return _buildBody(currentUser, viewModel);
              }),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedCrossFade(
                          firstChild: MainButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimension.padding,
                            ),
                            onPressed: () => viewModel.goToInstructions(context, currentUser.pudoProfile!),
                            text: 'Vedi istruzioni di consegna',
                          ),
                          secondChild: const SizedBox(),
                          crossFadeState: viewModel.editEnabled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 100)),
                      const SizedBox(height: Dimension.padding),
                      AnimatedCrossFade(
                          firstChild: MainButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimension.padding,
                            ),
                            onPressed: () => currentUser.refresh(),
                            text: 'Vai alla home',
                          ),
                          secondChild: const SizedBox(),
                          crossFadeState: viewModel.editEnabled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 100)),
                    ],
                  ))
            ]),
          ),
        );
      }),
    );
  }

  void goToRegistration() {}
}
