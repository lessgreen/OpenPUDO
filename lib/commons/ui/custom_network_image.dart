import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class CustomNetworkImage extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const CustomNetworkImage(
      {Key? key, required this.url, this.width, this.height, this.fit})
      : super(key: key);

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
