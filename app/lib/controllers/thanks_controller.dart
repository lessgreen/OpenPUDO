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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/widgets/main_button.dart';

class ThanksController extends StatefulWidget {
  const ThanksController({Key? key}) : super(key: key);

  @override
  _ThanksControllerState createState() => _ThanksControllerState();
}

class _ThanksControllerState extends State<ThanksController> {
  @override
  Widget build(BuildContext context) {
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
                    'mainLabel'.localized(context),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                  child: Text(
                    'secondaryLabel'.localized(context),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1Regular,
                  ),
                ),
                const Spacer(),
                SvgPicture.asset(ImageSrc.aboutYouArt, semanticsLabel: 'Art Background'),
                const Spacer(),
                MainButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimension.padding,
                  ),
                  onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.personalDataBusiness),
                  text: 'nextButton'.localized(context),
                ),
                const SizedBox(height: Dimension.padding),
                AnimatedCrossFade(
                  crossFadeState: isKeyboardVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  secondChild: const SizedBox(),
                  firstChild: MainButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'backButton'.localized(context),
                  ),
                  duration: const Duration(milliseconds: 150),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
