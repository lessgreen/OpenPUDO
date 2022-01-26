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

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class CustomNetworkImage extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const CustomNetworkImage({Key? key, required this.url, this.width, this.height, this.fit}) : super(key: key);

  @override
  _CustomNetworkImageState createState() => _CustomNetworkImageState();
}

class _CustomNetworkImageState extends State<CustomNetworkImage> {
  Uint8List? _buffer;

  @override
  void initState() {
    super.initState();
    _refreshData(widget.url);
  }

  _refreshData(String? pictureId) {
    if (pictureId == null) {
      setState(() {
        _buffer = null;
      });
      return;
    }
    NetworkManager.instance.profilePic(pictureId).then((value) {
      decodeImageFromList(value).then(
        (image) {
          setState(() {
            _buffer = value;
          });
        },
      ).catchError((onError) {
        setState(() {
          _buffer = null;
        });
      });
    }).catchError(
      (onError) {
        setState(() {
          _buffer = null;
        });
      },
    );
  }

  @override
  void didUpdateWidget(covariant CustomNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _refreshData(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buffer == null
        ? Image.asset(
            ImageSrc.imagePlaceHolder,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          )
        : Image.memory(
            _buffer!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          );
  }
}
