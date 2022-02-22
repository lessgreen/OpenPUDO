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
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

class AboutYouController extends StatefulWidget {
  const AboutYouController({Key? key}) : super(key: key);

  @override
  _AboutYouControllerState createState() => _AboutYouControllerState();
}

class _AboutYouControllerState extends State<AboutYouController> {
  @override
  Widget build(BuildContext context) {
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
                'Raccontaci qualcosa su di te',
                style: Theme.of(context).textTheme.headline6?.copyWith(letterSpacing: 0.6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Center(
                child: Text(
                  'Sei qui per ricevere un pacco\no per fornire un servizio di ritiro?',
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
                Navigator.of(context).pushReplacementNamed(Routes.userPosition);
              },
              text: 'Voglio ricevere un pacco',
            ),
            const SizedBox(height: Dimension.padding),
            MainButton(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimension.padding,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(Routes.personalDataBusiness);
              },
              text: 'Voglio fornire un servizio',
            ),
            const SizedBox(height: Dimension.paddingL)
          ],
        ),
      ),
    );
  }
}
