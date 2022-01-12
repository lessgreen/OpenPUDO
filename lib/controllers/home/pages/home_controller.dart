//
//  home_controller.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/controllers/home/di/home_controller_providers.dart';
import 'package:qui_green/controllers/home/viewmodel/home_controller_viewmodel.dart';

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
        return Scaffold(
          appBar: AppBar(title: const Text('Home')),
          body: const Center(
            child: Text('Hello'),
          ),
        );
      }),
    );
  }
}
