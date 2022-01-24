//
//   about_you_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Tue Jan 04 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
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
    //TODO implement provider
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
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(letterSpacing: 0.6),
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
            const SizedBox(
              height: Dimension.paddingL,
            ),
            SvgPicture.asset(ImageSrc.aboutYouArt,
                semanticsLabel: 'Art Background'),
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
                Navigator.of(context).pushReplacementNamed(Routes.home);
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
