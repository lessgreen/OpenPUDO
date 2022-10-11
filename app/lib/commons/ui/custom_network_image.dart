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
import 'package:flutter_svg/svg.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:transparent_image/transparent_image.dart';

class CustomNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool useSVGPlaceholder;
  final bool isCircle;
  final Widget? placeholderWidget;

  const CustomNetworkImage({
    Key? key,
    this.url,
    this.width,
    this.height,
    this.fit,
    this.placeholderWidget,
    this.useSVGPlaceholder = true,
    this.isCircle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sizedBox = SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          placeholderWidget ??
              SvgPicture.asset(
                ImageSrc.imageSVGPlaceHolder,
                width: width,
                height: height,
                fit: fit ?? BoxFit.cover,
              ),
          url == null
              ? const SizedBox()
              : FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: NetworkManager.instance.getProfilePicID(url!),
                  fit: fit ?? BoxFit.cover,
                )
        ],
      ),
    );
    return isCircle
        ? ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: sizedBox,
          )
        : ClipRect(
            child: sizedBox,
          );
  }
}
