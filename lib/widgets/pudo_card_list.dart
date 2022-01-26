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

import 'package:flutter/cupertino.dart';
import 'package:qui_green/widgets/pudo_map_card.dart';

class PudoCardList extends StatelessWidget {
  final Function(int) onPageChange;
  final Function() onTap;

  const PudoCardList({Key? key, required this.onPageChange, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: PageView.builder(
          onPageChanged: (index) => onPageChange(index),
          controller: PageController(viewportFraction: 1),
          itemCount: 2,
          itemBuilder: (context, index) => PudoMapCard(
                name: "Bar - La pinta",
                address: "Via ippolito, 8",
                stars: 3,
                onTap: onTap,
                image: 'https://cdn.skuola.net/news_foto/2017/descrizione-bar.jpg',
              )),
    );
  }
}
