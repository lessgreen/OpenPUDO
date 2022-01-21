//
//  pudoList_controller.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/widgets/base_page.dart';
import 'package:qui_green/controllers/list_pudos/di/pudo_list_controller_providers.dart';
import 'package:qui_green/controllers/list_pudos/viewmodel/pudo_list_controller_viewmodel.dart';
import 'package:qui_green/controllers/maps/widgets/pudo_map_card.dart';
import 'package:qui_green/models/page_type.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

class PudoListController extends StatefulWidget {
  const PudoListController({Key? key}) : super(key: key);

  @override
  _PudoListControllerState createState() => _PudoListControllerState();
}

class _PudoListControllerState extends State<PudoListController> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: pudoListControllerProviders,
      child: Consumer<PudoListControllerViewModel>(builder: (_, viewModel, __) {
        return BasePage(
          headerVisible: true,
          title: 'I tuoi pudo',
          showBackIcon: true,
          onPressedBack: () =>
              Navigator.of(context).pushReplacementNamed(Routes.profile),
          icon: const Icon(null),
          onPressedIcon: () => null,
          index: 0,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: Dimension.padding,
                  top: Dimension.padding,
                ),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'I tuoi pudo:',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.only(
                      left: Dimension.padding, right: Dimension.padding),
                  child: PudoMapCard(
                    name: "Bar - La pinta",
                    address: "Via ippolito, 8",
                    stars: 3,
                    onTap: () {},
                    image:
                        'https://cdn.skuola.net/news_foto/2017/descrizione-bar.jpg',
                  )),
            ],
          ),
        );
      }),
    );
  }
}
