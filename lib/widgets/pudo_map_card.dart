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
import 'package:qui_green/resources/res.dart';

class PudoMapCard extends StatelessWidget {
  final Function() onTap;
  final String? image;
  final String name;
  final String address;
  final int stars;
  final bool hasShadow;

  const PudoMapCard({
    Key? key,
    required this.onTap,
    this.image,
    required this.name,
    required this.address,
    required this.stars,
    this.hasShadow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
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
                  url: image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(
                width: Dimension.padding,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodyTextBold, //const TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: List<Widget>.generate(
                        5,
                        (index) => Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: (index + 1 <= stars) ? Colors.yellow.shade700 : Colors.grey.shade200,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimension.paddingS),
                    Text(
                      address,
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
