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
import 'package:focus_detector/focus_detector.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/commons/utilities/localization.dart';

class ContactUsController extends StatefulWidget {
  const ContactUsController({Key? key}) : super(key: key);

  @override
  _ContactUsControllerState createState() => _ContactUsControllerState();
}

class _ContactUsControllerState extends State<ContactUsController> {
  FocusNode _formField = FocusNode();
  String _feedback = "";

  @override
  void dispose() {
    _formField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onVisibilityGained: () {
        _formField.requestFocus();
      },
      child: Material(
        child: CupertinoPageScaffold(
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
          ),
          child: SAScaffold(
            isLoading: NetworkManager.instance.networkActivity,
            body: Padding(
              padding: const EdgeInsets.all(Dimension.paddingM),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      focusNode: _formField,
                      onChanged: (newValue) {
                        setState(() {
                          _feedback = newValue;
                        });
                      },
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText: 'contactUsPlaceHolder'.localized(context),
                        hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 0.5,
                            color: AppColors.labelDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: Dimension.paddingM,
                    ),
                    MainButton(
                      onPressed: () {
                        NetworkManager.instance.contactUs(_feedback).then(
                          (value) {
                            SAAlertDialog.displayAlertWithClose(
                              context,
                              'feedbackTitle'.localized(context),
                              'thanksFeedback'.localized(context),
                              completion: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ).catchError(
                          (onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError),
                        );
                      },
                      text: 'submitButton'.localized(context),
                      enabled: _feedback.isEmpty == false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //MARK: Actions

}
