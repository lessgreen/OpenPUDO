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

import 'package:flutter/material.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/commons/utilities/date_time_extension.dart';
import 'package:qui_green/resources/res.dart';

class PackageCard extends StatelessWidget {
  final Function() onTap;
  final String? image;
  final String name;
  final String address;
  final int stars;
  final DateTime? deliveryDate;
  final bool isRead;

  const PackageCard({Key? key, required this.onTap, required this.image, required this.name, required this.address, required this.stars, required this.deliveryDate, required this.isRead})
      : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimension.padding),
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.boxGreyNoOp,
                boxShadow: Shadows.baseShadow,
                borderRadius: const BorderRadius.all(Radius.circular(Dimension.borderRadiusS)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimension.borderRadiusS), bottomLeft: Radius.circular(Dimension.borderRadiusS)),
                    child: CustomNetworkImage(
                      url: image,
                      width: 110,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.paddingXS),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (deliveryDate != null) const SizedBox(height: Dimension.paddingS),
                          if (deliveryDate != null)
                            Text(
                              'Pacco consegnato il ' + deliveryDate!.ddmmyyyy,
                              style: Theme.of(context).textTheme.captionSmall,
                            ),
                          if (deliveryDate != null) const SizedBox(height: Dimension.padding),
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: Dimension.paddingXS),
                          Text(
                            address,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Row(
                            children: List<Widget>.generate(
                                stars > 5 ? 5 : stars,
                                (index) => Icon(
                                      Icons.star_rounded,
                                      color: Colors.yellow.shade700,
                                    )),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Positioned(
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(20))),
                    height: 30,
                    width: 30,
                    child: const Icon(
                      Icons.add_alert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  right: 10,
                  top: 0),
          ],
        ),
      );
}
