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
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/models/map_search_addresses_request.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/view_models/personal_data_business_controller_viewmodel.dart';
import 'package:qui_green/widgets/address_overlay_search.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/profile_pic_box.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalDataBusinessController extends StatefulWidget {
  const PersonalDataBusinessController({Key? key, required this.canGoBack, required this.phoneNumber, this.email}) : super(key: key);
  final bool canGoBack;
  final String phoneNumber;
  final String? email;

  @override
  _PersonalDataBusinessControllerState createState() => _PersonalDataBusinessControllerState();
}

class _PersonalDataBusinessControllerState extends State<PersonalDataBusinessController> {
  bool termsAndConditionsChecked = true;
  bool _addressValidationFailed = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PersonalDataBusinessControllerViewModel(widget.phoneNumber, widget.email),
      child: Consumer<PersonalDataBusinessControllerViewModel>(builder: (context, viewModel, _) {
        return KeyboardVisibilityBuilder(builder: (context, child, isKeyboardVisible) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: Text(
                'mainLabel'.localized(context),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
              backgroundColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              leading: widget.canGoBack
                  ? CupertinoNavigationBarBackButton(
                      color: AppColors.primaryColorDark,
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : null,
            ),
            body: Column(children: [
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
                  child: ListView(children: [
                    const SizedBox(
                      height: Dimension.padding,
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                        child: Text(
                          'secondaryLabel'.localized(context),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subtitle1,
                        )),
                    const SizedBox(
                      height: Dimension.padding,
                    ),
                    ProfilePicBox(
                      onTap: () => viewModel.pickFile(context),
                      image: viewModel.image,
                      mainIcon: Icons.apartment,
                      title: 'addPhoto'.localized(context),
                    ),
                    const SizedBox(height: Dimension.padding),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Dimension.paddingM, 16, Dimension.paddingM, 0),
                      child: CupertinoTextField(
                        placeholder: 'placeHolderName'.localized(context),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        onChanged: (newValue) => viewModel.name = newValue,
                        onTap: () {
                          setState(() {});
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Dimension.paddingM, 16, Dimension.paddingM, 0),
                      child: CupertinoTextField(
                        placeholder: 'placeHolderAddress'.localized(context),
                        controller: viewModel.addressController,
                        decoration: _buildAddressBoxDecoration(),
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
                        decoration: const BoxDecoration(boxShadow: Shadows.baseShadow),
                        margin: const EdgeInsets.symmetric(vertical: Dimension.paddingS, horizontal: Dimension.padding),
                        child: AddressOverlaySearch(
                          borderRadius: BorderRadius.zero,
                          onTap: (GeoMarker marker) {
                            if (marker.signature != null) {
                              NetworkManager.instance.getPlacemarkDetails(MapSearchAddressesRequest(text: marker.signature!)).then((markerDetails) {
                                viewModel.address = viewModel.convertGeoMarker(markerDetails);
                                viewModel.addressController.text = markerDetails.address.label ?? "";
                                viewModel.isOpenListAddress = false;
                              }).catchError((onError) {
                                SAAlertDialog.displayAlertWithClose(
                                  context,
                                  "genericErrorTitle".localized(context, 'general'),
                                  onError,
                                  barrierDismissable: false,
                                );
                              });
                            }
                          },
                          addresses: viewModel.addresses,
                        ),
                      ),
                      crossFadeState: viewModel.isOpenListAddress ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 150),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Dimension.paddingM, 16, Dimension.paddingM, 0),
                      child: CupertinoTextField(
                        placeholder: 'placeHolderPhone'.localized(context),
                        controller: viewModel.phoneNumberController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                        autofocus: false,
                        onChanged: (newValue) => viewModel.phoneNumber = newValue,
                        onTap: () {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: Dimension.paddingM, right: Dimension.paddingM),
                        child: Text(
                          'hintPhone'.localized(context),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Dimension.paddingM, 16, Dimension.paddingM, 0),
                      child: CupertinoTextField(
                        placeholder: 'placeHolderEmail'.localized(context),
                        controller: viewModel.emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                        autofocus: false,
                        onChanged: (newValue) => viewModel.email = newValue,
                        onTap: () {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                            text: TextSpan(style: Theme.of(context).textTheme.caption, children: [
                              TextSpan(
                                text: 'acceptTermsAndCondition'.localized(context),
                              ),
                              TextSpan(
                                  text: 'termsAndConditionHyperlink'.localized(context),
                                  style: Theme.of(context).textTheme.bodyTextItalicBoldAccent,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launch('https://tools.quigreen.it/terms.html');
                                    }),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                  ]),
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
                        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          MaterialButton(
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: Text(
                              'doneButton'.localized(context),
                              style: Theme.of(context).textTheme.bodyTextAccent,
                            ),
                          )
                        ]),
                      ),
                    )),
                firstChild: const SizedBox(),
                duration: const Duration(milliseconds: 150),
              ),
            ]),
            bottomSheet: AnimatedCrossFade(
              crossFadeState: isKeyboardVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              secondChild: const SizedBox(),
              firstChild: FutureBuilder<bool>(
                future: viewModel.isValid,
                builder: (context, snapshot) {
                  return MainButton(
                    enabled: (snapshot.data ?? false) && termsAndConditionsChecked,
                    onPressed: () {
                      setState(() {
                        _addressValidationFailed = (viewModel.address == null);
                      });
                      if (viewModel.address != null) {
                        Navigator.of(context).pushReplacementNamed(Routes.rewardPolicy, arguments: viewModel.buildRequest());
                      } else {
                        SAAlertDialog.displayAlertWithClose(
                            context, 'genericErrorTitle'.localized(context, 'general'), 'specifyValidAddress'.localized(context, 'PersonalDataBusinessControllerState'));
                      }
                    },
                    text: 'nextButton'.localized(context),
                  );
                },
              ),
              duration: const Duration(milliseconds: 150),
            ),
          );
        });
      }),
    );
  }

  BoxDecoration _buildAddressBoxDecoration() {
    if (!_addressValidationFailed) {
      return BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor)));
    }
    return const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.red)));
  }
}
