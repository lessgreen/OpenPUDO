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
import 'package:provider/provider.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/controllers/user_position/di/user_position_controller_providers.dart';
import 'package:qui_green/controllers/user_position/viewmodel/user_position_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';

class UserPositionController extends StatefulWidget {
  const UserPositionController({Key? key}) : super(key: key);

  @override
  _UserPositionControllerState createState() => _UserPositionControllerState();
}

class _UserPositionControllerState extends State<UserPositionController> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: userPositionControllerProviders,
        child: Consumer<UserPositionControllerViewModel?>(
            builder: (_, viewModel, __) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                leading: const SizedBox(),
              ),
              body: Column(
                children: [
                  Center(
                    child: Text(
                      'Vediamo dove ti trovi',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Center(
                      child: Text(
                        'Per poterti fornire informazioni rilevanti\nabbiamo bisogno di accedere alla tua posizione.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: Dimension.paddingL,
                  ),
                  SvgPicture.asset(ImageSrc.userPositionArt,
                      semanticsLabel: 'Art Background'),
                  const Spacer(),
                  MainButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimension.padding),
                    onPressed: () async {
                      await viewModel?.tryGetUserLocation().then((value) {
                        //print("acquired position: $value");
                      });
                    },
                    text: 'Ok, grazie!',
                  ),
                  const SizedBox(height: Dimension.padding),
                  MainButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimension.padding,
                    ),
                    onPressed: () => viewModel?.onAddAddressClick(context),
                    text: 'Inserisci indirizzo',
                  ),
                  const SizedBox(height: Dimension.paddingL)
                ],
              ),
            ),
          );
        }));
  }
}
