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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/view_models/personal_data_controller_viewmodel.dart';
import 'package:qui_green/widgets/profile_pic_box.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalDataController extends StatefulWidget {
  const PersonalDataController({Key? key, this.pudoDataModel}) : super(key: key);
  final PudoProfile? pudoDataModel;

  @override
  _PersonalDataControllerState createState() => _PersonalDataControllerState();
}

class _PersonalDataControllerState extends State<PersonalDataController> with ConnectionAware {
  bool termsAndConditionsChecked = true;

  void _showErrorDialog(BuildContext context, String val) => SAAlertDialog.displayAlertWithClose(
        context,
        'genericErrorTitle'.localized(context, 'general'),
        val,
      );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PersonalDataControllerViewModel(),
      child: Consumer<PersonalDataControllerViewModel?>(
        builder: (_, viewModel, __) {
          viewModel?.showErrorDialog = (String val) => _showErrorDialog(context, val);
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
                ),
                body: ListView(
                  children: [
                    Center(
                      child: Text(
                        'mainLabel'.localized(context),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    const SizedBox(
                      height: Dimension.paddingM,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                        child: Text(
                          'secondaryLabel'.localized(context),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        )),
                    const SizedBox(
                      height: Dimension.paddingM,
                    ),
                    ProfilePicBox(
                      onTap: () => viewModel!.pickFile(),
                      image: viewModel!.image,
                      title: 'addPhoto'.localized(context),
                    ),
                    const SizedBox(height: Dimension.padding),
                    Center(
                      child: Text(
                        'or'.localized(context),
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: CupertinoTextField(
                        placeholder: 'placeHolderName'.localized(context),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                        ),
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        onChanged: (newValue) {
                          viewModel.name = newValue;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: CupertinoTextField(
                        placeholder: 'placeHolderSurname'.localized(context),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                        ),
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        onChanged: (newValue) {
                          viewModel.surname = newValue;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                      child: Text(
                        'hintNameAndSurname'.localized(context),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            activeColor: AppColors.primaryColorDark,
                            value: termsAndConditionsChecked,
                            onChanged: (value) {
                              setState(() {
                                termsAndConditionsChecked = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                style: Theme.of(context).textTheme.caption,
                                children: [
                                  TextSpan(
                                    text: 'acceptTermsAndCondition'.localized(context),
                                  ),
                                  TextSpan(
                                    text: 'termsAndConditionHyperlink'.localized(context),
                                    style: const TextStyle(color: AppColors.primaryColorDark, fontWeight: FontWeight.w500),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launch('https://tools.quigreen.it/terms.html');
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomSheet: AnimatedCrossFade(
                  crossFadeState: isKeyboardVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  secondChild: const SizedBox(
                    width: double.infinity,
                  ),
                  firstChild: MainButton(
                    enabled: viewModel.isValid && termsAndConditionsChecked,
                    onPressed: () => viewModel.onSendClick(context, widget.pudoDataModel),
                    text: 'submitButton'.localized(context),
                  ),
                  duration: const Duration(milliseconds: 150),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
