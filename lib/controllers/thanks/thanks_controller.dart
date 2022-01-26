//
//   user_position_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Wed Jan 05 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

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
                  'Grazie per averci scelto!',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 3 * 2,
                  child: Text(
                    'Divendando un PUDO QuiGreen potrai fornire un servizio a tutti gli utenti che vorranno ricevere un pacco, ricevendolo tu per loro.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        ?.copyWith(fontWeight: FontWeight.w400),
                  )),
              const Spacer(),
              SvgPicture.asset(ImageSrc.aboutYouArt,
                  semanticsLabel: 'Art Background'),
              const Spacer(),
              MainButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimension.padding,
                ),
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(Routes.personalDataBusiness),
                text: 'Avanti',
              ),
              const SizedBox(height: Dimension.padding),
              AnimatedCrossFade(
                crossFadeState: isKeyboardVisible
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                secondChild: const SizedBox(),
                firstChild: MainButton(
                  onPressed: () => Navigator.of(context).pop(),
                  text: 'Indietro',
                ),
                duration: const Duration(milliseconds: 150),
              ),
            ],
          ),
        ),
      );
    });
  }
}
