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
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/controllers/registration_complete/di/registration_complete_controller_providers.dart';
import 'package:qui_green/controllers/registration_complete/viewmodel/registration_complete_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

class RegistrationCompleteController extends StatefulWidget {
  const RegistrationCompleteController({Key? key}) : super(key: key);

  @override
  _RegistrationCompleteControllerState createState() =>
      _RegistrationCompleteControllerState();
}

class _RegistrationCompleteControllerState
    extends State<RegistrationCompleteController> {
  final FocusNode _address = FocusNode();
  String _addressValue = "";

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: registrationCompleteControllerProviders,
        child: Consumer<RegistrationCompleteControllerViewModel?>(
            builder: (_, viewModel, __) {
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
                        'Fatto!',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        padding: EdgeInsets.only(
                            left: Dimension.padding, right: Dimension.padding),
                        child: Text(
                          'Adesso potrai usare questo indirizzo per farti inviare i tuoi pacchi in totale comodità!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        )),
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: Dimension.padding, right: Dimension.padding),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                              Radius.circular(Dimension.borderRadiusS)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft:
                                      Radius.circular(Dimension.borderRadiusS),
                                  bottomLeft:
                                      Radius.circular(Dimension.borderRadiusS)),
                              child: Image.network(
                                'https://cdn.skuola.net/news_foto/2017/descrizione-bar.jpg',
                                width: 110,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Column(
                              children: [
                                Spacer(),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding:
                                      EdgeInsets.only(left: Dimension.padding),
                                  child: Text(
                                    'Bar - La pinta',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  padding:
                                      EdgeInsets.only(left: Dimension.padding),
                                  child: Text(
                                    'Via ippolito, 8',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                Container(
                                  padding:
                                      EdgeInsets.only(left: Dimension.padding),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.yellow.shade700,
                                      ),
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.yellow.shade700,
                                      ),
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.yellow.shade700,
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(Dimension.padding),
                              child: Image.asset('assets/hand.png'),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: Dimension.padding, right: Dimension.padding),
                      child: Row(
                        children: [
                          Switch(value: true, onChanged: (bool newValue) => {}),
                          Text(
                            'Permetti al pudo di contattarmi\nal mio numero telefonico in caso\ndi comunicazioni inerenti\ni miei pacchi.',
                            style: TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    MainButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimension.padding,
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(Routes.instruction);
                      },
                      text: 'Vedi le istruzioni',
                    ),
                    SizedBox(height: 10),
                    AnimatedCrossFade(
                      crossFadeState: isKeyboardVisible
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      secondChild: const SizedBox(),
                      firstChild: MainButton(
                        onPressed: () => viewModel!.onSendClick(context),
                        text: 'Vai alla home',
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
