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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qui_green/resources/res.dart';

class ProfilePicBox extends StatelessWidget {
  final Function()? onTap;
  final File? image;
  final IconData? mainIcon;
  final String? mainIconSvgAsset;
  final String title;

  const ProfilePicBox({
    Key? key,
    this.onTap,
    this.image,
    this.mainIcon = Icons.account_circle_rounded,
    this.mainIconSvgAsset,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(Dimension.borderRadius)),
            onTap: onTap,
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.width / 3,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: const BorderRadius.all(
                  Radius.circular(Dimension.borderRadius),
                ),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(Dimension.borderRadius)),
                      child: Image.file(
                        image!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (mainIconSvgAsset != null)
                          SvgPicture.asset(
                            mainIconSvgAsset!,
                            color: Colors.grey.shade400,
                            width: MediaQuery.of(context).size.width / 6,
                            height: MediaQuery.of(context).size.width / 6,
                          ),
                        if (mainIconSvgAsset == null)
                          Icon(
                            mainIcon,
                            color: Colors.grey.shade400,
                            size: MediaQuery.of(context).size.width / 6,
                          ),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      );
}
