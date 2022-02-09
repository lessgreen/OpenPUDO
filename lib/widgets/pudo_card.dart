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
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/widgets/pudo_map_card.dart';

class PudoCard extends StatelessWidget {
  final Function() onTap;
  final PudoProfile pudo;

  const PudoCard({Key? key, required this.onTap, required this.pudo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: PudoMapCard(
        name: pudo.businessName,
        address: pudo.address?.street ?? "Via Ippolito, 8",
        stars: pudo.ratingModel?.reviewCount ?? 3,
        image: pudo.pudoPicId,
        onTap: onTap,
      ),
    );
  }
}
