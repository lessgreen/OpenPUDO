//
//  SANetworkImage.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 03/07/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:open_pudo/singletons/network.dart';

class SANetworkImage extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  SANetworkImage({Key? key, required this.url, this.width, this.height, this.fit}) : super(key: key);

  @override
  _SANetworkImageState createState() => _SANetworkImageState();
}

class _SANetworkImageState extends State<SANetworkImage> {
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
    NetworkManager().profilePic(pictureId).then((value) {
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
  void didUpdateWidget(covariant SANetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _refreshData(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buffer == null
        ? Image.asset(
            'assets/placeholderImage.jpg',
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
