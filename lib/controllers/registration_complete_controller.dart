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
import 'package:provider/provider.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/pudo_map_card.dart';
import 'package:qui_green/view_models/registration_complete_controller_viewmodel.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/res.dart';

class RegistrationCompleteController extends StatefulWidget {
  const RegistrationCompleteController({Key? key, this.pudoDataModel}) : super(key: key);
  final PudoProfile? pudoDataModel;

  @override
  _RegistrationCompleteControllerState createState() => _RegistrationCompleteControllerState();
}

class _RegistrationCompleteControllerState extends State<RegistrationCompleteController> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => RegistrationCompleteControllerViewModel(),
        child: Consumer<RegistrationCompleteControllerViewModel?>(builder: (_, viewModel, __) {
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
                        'Fatto!',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 3 * 2,
                        child: Text(
                          'Adesso potrai usare questo indirizzo per farti inviare i tuoi pacchi in totale comodità!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w400),
                        )),
                    if (widget.pudoDataModel != null) const SizedBox(height: Dimension.paddingL),
                    if (widget.pudoDataModel != null)
                      Padding(
                          padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                          child: PudoMapCard(
                              name: widget.pudoDataModel?.businessName ?? "",
                              address: widget.pudoDataModel?.address?.label ?? "",
                              stars: widget.pudoDataModel?.ratingModel?.stars ?? 0,
                              onTap: () {},
                              image: widget.pudoDataModel?.pudoPicId ?? 'https://cdn.skuola.net/news_foto/2017/descrizione-bar.jpg')),
                    const SizedBox(height: Dimension.paddingL),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                      child: RichText(
                        text: TextSpan(
                          text: '',
                          style: Theme.of(context).textTheme.bodyText1,
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: CupertinoSwitch(
                                  trackColor: Colors.grey.shade200,
                                  activeColor: AppColors.primaryColorDark,
                                  value: viewModel!.showNumber,
                                  onChanged: (bool newValue) => viewModel.showNumber = newValue),
                            ),
                            const WidgetSpan(
                              child: SizedBox(
                                width: Dimension.padding,
                              ),
                            ),
                            TextSpan(
                              text: 'Permetti ai pudo di contattarmi al mio numero telefonico in caso di comunicazioni inerenti i miei pacchi.',
                              style: Theme.of(context).textTheme.subtitle1?.copyWith(fontStyle: FontStyle.italic, height: 1.5, letterSpacing: 0),
                            ),
                          ],
                        ),
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
                        onPressed: () => viewModel.onOkClick(context),
                        text: 'Vai alla home',
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
