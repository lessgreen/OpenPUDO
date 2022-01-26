//
//   user_position_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Wed Jan 05 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/view_models/personal_data_controller_viewmodel.dart';
import 'package:qui_green/controllers/personal_data/widgets/profile_pic_box.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/res.dart';

class PersonalDataController extends StatefulWidget {
  const PersonalDataController({Key? key, this.pudoDataModel})
      : super(key: key);
  final PudoProfile? pudoDataModel;

  @override
  _PersonalDataControllerState createState() => _PersonalDataControllerState();
}

class _PersonalDataControllerState extends State<PersonalDataController> {
  void _showErrorDialog(BuildContext context, String val) =>
      SAAlertDialog.displayAlertWithClose(context, "Error", val);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProxyProvider0<PersonalDataControllerViewModel?>(
              create: (context) => PersonalDataControllerViewModel(),
              update: (context, viewModel) => viewModel),
        ],
        child: Consumer<PersonalDataControllerViewModel?>(
            builder: (_, viewModel, __) {
          viewModel?.showErrorDialog =
              (String val) => _showErrorDialog(context, val);
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
                        'Ancora qualche informazione',
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
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Theme.of(context).primaryColor))),
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
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Theme.of(context).primaryColor))),
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        onChanged: (newValue) {
                          viewModel.surname = newValue;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(
                          left: Dimension.padding, right: Dimension.padding),
                      child: Text(
                        'Se usi il nome e cognome come sistema di identificazione, dovrai esibire un documento valido per il ritiro.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    AnimatedCrossFade(
                      crossFadeState: isKeyboardVisible
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      secondChild: const SizedBox(),
                      firstChild: MainButton(
                        enabled: viewModel.isValid,
                        onPressed: () => viewModel.onSendClick(
                            context, widget.pudoDataModel),
                        text: 'Invia',
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
