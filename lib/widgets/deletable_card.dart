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
import 'package:flutter/rendering.dart';
import 'package:qui_green/resources/res.dart';

class DeletableCard extends StatefulWidget {
  final Function() onDelete;
  final int id;
  final double maxWidth;
  final Function(bool) onOpenStateChange;
  final bool isOpened;
  final Widget card;

  const DeletableCard({Key? key, required this.id, required this.onDelete, required this.onOpenStateChange, required this.isOpened, this.maxWidth = 100, required this.card}) : super(key: key);

  @override
  State<DeletableCard> createState() => _DeletableCardState();
}

class _DeletableCardState extends State<DeletableCard> with TickerProviderStateMixin {
  double deleteSize = 0;
  double maxSize = 100;
  Offset? start;
  Offset? end;
  ScrollDirection? direction;
  int? _oldId;

  @override
  void initState() {
    super.initState();
    maxSize = widget.maxWidth;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void animateDelete(bool open) {
    widget.onOpenStateChange(open);
    final _zoomTween = Tween<double>(begin: deleteSize, end: open ? maxSize : 0);
    var controller = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
    Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
    controller.addListener(() {
      setState(() {
        deleteSize = _zoomTween.evaluate(animation);
      });
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  double get getSafeOffset => deleteSize - Dimension.padding < 0 ? 0 : deleteSize - Dimension.padding;

  void triggerCorrectActionForOpen(double size) {
    if (size == 100) {
      widget.onOpenStateChange(true);
    } else if (size == 0) {
      widget.onOpenStateChange(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_oldId != null) {
      if (_oldId! != widget.id) {
        animateDelete(widget.isOpened);
      }
    }
    _oldId = widget.id;
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails startDetails) {
        start = startDetails.localPosition;
      },
      onHorizontalDragEnd: (DragEndDetails endDetails) {
        triggerCorrectActionForOpen(deleteSize);
        if (deleteSize > maxSize / 2 && deleteSize <= maxSize) {
          animateDelete(true);
        }
        if (deleteSize <= maxSize / 2 && deleteSize >= 0) {
          animateDelete(false);
        }
        end = start;
        direction = null;
      },
      onHorizontalDragUpdate: (DragUpdateDetails updateDetails) {
        end = updateDetails.localPosition;
        if ((start?.dx ?? 0) - updateDetails.localPosition.dx > 0) {
          direction ??= ScrollDirection.forward;
          //Open
          if (deleteSize != maxSize) {
            setState(() {
              double newSize = (start?.dx ?? 0) - updateDetails.localPosition.dx;
              if (newSize > maxSize) {
                newSize = deleteSize;
              } else if (newSize < 0) {
                newSize = 0;
              }
              if (direction == ScrollDirection.forward) {
                deleteSize = newSize;
              }
            });
          }
        } else {
          direction ??= ScrollDirection.reverse;
          //Close
          if (deleteSize != 0) {
            setState(() {
              double newSize = (maxSize + ((start?.dx ?? 0) - updateDetails.localPosition.dx));
              if (newSize > maxSize) {
                newSize = deleteSize;
              } else if (newSize < 0) {
                newSize = 0;
              }
              if (direction == ScrollDirection.reverse) {
                deleteSize = newSize;
              }
            });
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimension.paddingS),
        child: Stack(children: [
          Transform.translate(
              offset: Offset(0 - getSafeOffset, 0),
              child: SizedBox(
                height: 100,
                child: widget.card,
              )),
          Positioned(
            right: Dimension.padding,
            child: InkWell(
              onTap: widget.onDelete,
              child: AnimatedContainer(
                decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(Dimension.borderRadiusS), boxShadow: Shadows.baseShadow),
                duration: const Duration(milliseconds: 10),
                height: 100,
                width: deleteSize,
                child: const Icon(
                  Icons.delete_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
