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
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/view_models/personal_data_controller_viewmodel.dart';
import 'package:qui_green/widgets/profile_pic_box.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class PersonalDataController extends StatefulWidget {
  const PersonalDataController({Key? key, this.pudoDataModel}) : super(key: key);
  final PudoProfile? pudoDataModel;

  @override
  _PersonalDataControllerState createState() => _PersonalDataControllerState();
}

class _PersonalDataControllerState extends State<PersonalDataController> {
  void _showErrorDialog(BuildContext context, String val) => SAAlertDialog.displayAlertWithClose(context, "Error", val);

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
                        'Ancora qualche informazione',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    const SizedBox(
                      height: Dimension.paddingM,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                        child: const Text(
                          'Per poterti identificare quando il tuo pacco arriverà, abbiamo bisogno di qualche altro dato.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        )),
                    const SizedBox(
                      height: Dimension.paddingM,
                    ),
                    ProfilePicBox(
                      onTap: () => viewModel!.pickFile(),
                      image: viewModel!.image,
                    ),
                    const SizedBox(height: Dimension.padding),
                    const Center(
                      child: Text(
                        'oppure',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: CupertinoTextField(
                        placeholder: 'Nome',
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
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
                        placeholder: 'Cognome',
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        onChanged: (newValue) {
                          viewModel.surname = newValue;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                      child: Text(
                        'Se usi il nome e cognome come sistema di identificazione, dovrai esibire un documento valido per il ritiro.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    AnimatedCrossFade(
                      crossFadeState: isKeyboardVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      secondChild: const SizedBox(),
                      firstChild: MainButton(
                        enabled: viewModel.isValid,
                        onPressed: () => viewModel.onSendClick(context, widget.pudoDataModel),
                        text: 'Invia',
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
