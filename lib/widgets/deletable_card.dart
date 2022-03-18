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
  final Function() onOpenStateChange;
  final int? openedId;
  final Widget card;
  final double rowHeight;
  final double horizontalPadding;
  final EdgeInsets itemPadding;
  final BorderRadius borderRadius;

  const DeletableCard({
    Key? key,
    required this.id,
    required this.onDelete,
    required this.onOpenStateChange,
    required this.openedId,
    this.maxWidth = 100,
    required this.card,
    required this.itemPadding,
    required this.rowHeight,
    required this.horizontalPadding,
    required this.borderRadius,
  }) : super(key: key);

  @override
  State<DeletableCard> createState() => DeletableCardState();
}

class DeletableCardState extends State<DeletableCard> with TickerProviderStateMixin {
  double deleteSize = 0;
  double maxSize = 100;
  Offset? start;
  Offset? end;
  ScrollDirection? direction;

  @override
  void initState() {
    super.initState();
    maxSize = widget.maxWidth;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void closeCard() {
    animateDelete(false, notify: false);
  }

  void animateDelete(bool open, {bool notify = true}) {
    if (notify) {
      widget.onOpenStateChange();
    }

    final _zoomTween = Tween<double>(begin: deleteSize, end: open ? maxSize : 0);
    var controller = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
    Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: open ? Curves.easeIn : Curves.easeOut,
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

  double get getSafeOffset => deleteSize - widget.horizontalPadding < 0 ? 0 : deleteSize - widget.horizontalPadding;

  void triggerCorrectActionForOpen(double size) {
    if (size == 100) {
      widget.onOpenStateChange();
    } else if (size == 0) {
      widget.onOpenStateChange();
    }
  }

  void safeAnimate(bool open, {bool notify = true}) {
    if (start == null) {
      animateDelete(open, notify: notify);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        start = null;
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
        padding: widget.itemPadding,
        child: Stack(children: [
          Transform.translate(
              offset: Offset(0 - getSafeOffset, 0),
              child: SizedBox(
                child: widget.card,
              )),
          Positioned(
            right: widget.horizontalPadding,
            child: InkWell(
              onTap: widget.onDelete,
              child: AnimatedContainer(
                height: widget.rowHeight,
                decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: widget.borderRadius, boxShadow: Shadows.baseShadow),
                duration: const Duration(milliseconds: 10),
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
