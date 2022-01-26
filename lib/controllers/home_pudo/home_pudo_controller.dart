//
//  homePudo_controller.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.


// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/controllers/maps/widgets/pudo_map_card.dart';
import 'package:qui_green/models/page_type.dart';
import 'package:qui_green/resources/routes_enum.dart';

class HomePudoController extends StatefulWidget {
  const HomePudoController({Key? key}) : super(key: key);

  @override
  _HomePudoControllerState createState() => _HomePudoControllerState();
}

class _HomePudoControllerState extends State<HomePudoController> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      'Non hai ancora aggiunto un pudo per le tue consegne!',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey.shade600),
    ));
  }
}
