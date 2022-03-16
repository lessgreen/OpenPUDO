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
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/pudo_summary.dart';
import 'package:qui_green/resources/res.dart';

class PudoCard extends StatelessWidget {
  final PudoCardRepresentation dataSource;
  final Function() onTap;
  final Function()? onLongPress;
  final bool hasShadow;
  final bool showCustomizedAddress;

  const PudoCard({
    Key? key,
    required this.dataSource,
    required this.onTap,
    this.onLongPress,
    this.hasShadow = false,
    this.showCustomizedAddress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var computedStars = (dataSource.rating?.stars ?? 0).toInt();
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimension.padding),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(Dimension.borderRadiusS)),
          boxShadow: hasShadow ? Shadows.baseShadow : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimension.borderRadiusS),
                bottomLeft: Radius.circular(Dimension.borderRadiusS),
              ),
              child: CustomNetworkImage(
                url: dataSource.pudoPicId,
                width: 110,
                height: 100,
              ),
            ),
            const SizedBox(
              width: Dimension.padding,
            ),
            Expanded(
              child: showCustomizedAddress == false
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dataSource.businessName,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodyTextBold,
                        ),
                        Row(
                          children: List<Widget>.generate(
                            5,
                            (index) => Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: (index + 1 <= computedStars) ? Colors.yellow.shade700 : Colors.grey.shade200,
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimension.paddingS),
                        Text(
                          dataSource.computedAddress ?? "--",
                          maxLines: 2,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'shipmentAddress'.localized(context),
                          style: Theme.of(context).textTheme.caption,
                        ),
                        const SizedBox(height: Dimension.paddingS),
                        Text(
                          dataSource.customizedAddress ?? "--",
                          maxLines: 2,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
            ),
            const SizedBox(
              width: Dimension.padding,
            ),
          ],
        ),
      ),
    );
  }
}
