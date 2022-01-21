//
//  home_controller.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/widgets/base_page.dart';
import 'package:qui_green/controllers/home/di/home_controller_providers.dart';
import 'package:qui_green/controllers/home/viewmodel/home_controller_viewmodel.dart';
import 'package:qui_green/models/page_type.dart';
import 'package:qui_green/resources/routes_enum.dart';

class HomeController extends StatefulWidget {
  const HomeController({Key? key}) : super(key: key);

  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: homeControllerProviders,
      child: Consumer<HomeControllerViewModel>(builder: (_, viewModel, __) {
        return BasePage(
          title: 'QuiGreen',
          showBackIcon: false,
          onPressedBack: () => Navigator.of(context).pop(),
          index: 0,
          headerVisible: true,
          icon: const Icon(Icons.account_circle),
          onPressedIcon: () =>
              Navigator.of(context).pushReplacementNamed(Routes.profile),
          body: Center(
              child: Text(
            'Non ci sono ancora consegne in attesa per te!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          )),
        );
      }),
    );
  }
}
