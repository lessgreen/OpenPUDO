//
//  pudoList_controller.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qui_green/controllers/maps/widgets/pudo_map_card.dart';
import 'package:qui_green/resources/res.dart';

class PudoListController extends StatefulWidget {
  const PudoListController({Key? key}) : super(key: key);

  @override
  _PudoListControllerState createState() => _PudoListControllerState();
}

class _PudoListControllerState extends State<PudoListController> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: AppColors.primaryColorDark,
          middle: Text(
            'Il tuoi pudo',
            style: Theme.of(context)
                .textTheme
                .headline6
                ?.copyWith(color: Colors.white),
          ),
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        child: Column(
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
            const SizedBox(height: 10),
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
      ),
    );
  }
}
