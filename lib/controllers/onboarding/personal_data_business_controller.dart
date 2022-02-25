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
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/view_models/personal_data_business_controller_viewmodel.dart';
import 'package:qui_green/widgets/address_overlay_search.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/profile_pic_box.dart';

class PersonalDataBusinessController extends StatefulWidget {
  const PersonalDataBusinessController({Key? key}) : super(key: key);

  @override
  _PersonalDataBusinessControllerState createState() => _PersonalDataBusinessControllerState();
}

class _PersonalDataBusinessControllerState extends State<PersonalDataBusinessController> {
  TextEditingController controller = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PersonalDataBusinessControllerViewModel(),
      child: Consumer<PersonalDataBusinessControllerViewModel>(builder: (context, viewModel, _) {
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
              body: ListView(
                children: [
                  Center(
                    child: Text(
                      'Qualche informazione sulla tua attività',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  const SizedBox(
                    height: Dimension.paddingM,
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                      child: const Text(
                        'Per farti trovare dagli utenti dovresti dirci qualcosa in più della tua attività.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      )),
                  const SizedBox(
                    height: Dimension.paddingM,
                  ),
                  ProfilePicBox(
                    onTap: viewModel.pickFile,
                    image: viewModel.image,
                    mainIcon: Icons.apartment,
                  ),
                  const SizedBox(height: Dimension.padding),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: CupertinoTextField(
                      placeholder: 'Nome attività',
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                      autofocus: false,
                      textInputAction: TextInputAction.done,
                      onChanged: (newValue)=>viewModel.name=newValue,
                      onTap: () {
                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: CupertinoTextField(
                      placeholder: 'Inserisci il tuo indirizzo',
                      controller: viewModel.addressController,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                      autofocus: false,
                      textInputAction: TextInputAction.done,
                      onChanged: (newValue) => viewModel.onSearchChanged(newValue),
                      onTap: () {
                        setState(() {});
                      },
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: SizedBox(width: MediaQuery.of(context).size.width),
                    secondChild: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimension.borderRadiusS), border: Border.all(color: Colors.black)),
                      margin: const EdgeInsets.symmetric(vertical: Dimension.paddingS, horizontal: Dimension.padding),
                      child: AddressOverlaySearch(
                        onTap: (GeoMarker marker) {
                          viewModel.address = viewModel.convertGeoMarker(marker);
                          viewModel.addressController.text=marker.address!.label??"";
                          viewModel.isOpenListAddress = false;
                        },
                        addresses: viewModel.addresses,
                      ),
                    ),
                    crossFadeState: viewModel.isOpenListAddress ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 150),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: CupertinoTextField(
                      placeholder: 'Telefono',
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                      autofocus: false,
                      textInputAction: TextInputAction.done,
                      onChanged: (newValue)=>viewModel.phoneNumber=newValue,
                      onTap: () {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                      child: Text(
                        'Questo è il numero mostrato al pubblico. Se preferisci, puoi modificarlo.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              bottomSheet: AnimatedCrossFade(
                crossFadeState: isKeyboardVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                secondChild: const SizedBox(),
                firstChild: MainButton(
                  enabled: viewModel.isValid,
                  onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.rewardPolicy,arguments: viewModel.buildRequest()),
                  text: 'Avanti',
                ),
                duration: const Duration(milliseconds: 150),
              ),
            ),
          );
        });
      }),
    );
  }
}
