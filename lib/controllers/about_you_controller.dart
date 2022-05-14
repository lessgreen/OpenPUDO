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
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class AboutYouController extends StatefulWidget {
  const AboutYouController({Key? key, this.phoneNumber}) : super(key: key);
  final String? phoneNumber;
  @override
  _AboutYouControllerState createState() => _AboutYouControllerState();
}

class _AboutYouControllerState extends State<AboutYouController> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SAScaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: CupertinoNavigationBarBackButton(
            color: AppColors.primaryColorDark,
            onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.insertPhone),
          ),
        ),
        body: Column(
          children: [
            Text(
              'mainLabel'.localized(context),
              style: Theme.of(context).textTheme.headline6,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Center(
                child: Text(
                  'secondaryLabel'.localized(context),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
            const Spacer(),
            SvgPicture.asset(ImageSrc.aboutYouArt, semanticsLabel: 'Art Background'),
            const Spacer(),
            MainButton(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimension.padding,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.userPosition);
              },
              text: 'standardUserButton'.localized(context),
            ),
            const SizedBox(height: Dimension.padding),
            MainButton(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimension.padding,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.personalDataBusiness, arguments: widget.phoneNumber);
              },
              text: 'pudoUserButton'.localized(context),
            ),
            const SizedBox(height: Dimension.paddingL)
          ],
        ),
      ),
    );
  }
}
