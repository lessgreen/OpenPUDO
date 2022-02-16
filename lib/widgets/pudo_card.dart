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
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/models/pudo_summary.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/widgets/pudo_map_card.dart';

class PudoCard extends StatefulWidget {
  final Function() onTap;
  final Function() onDelete;
  final PudoSummary pudo;
  final double maxWidth;

  const PudoCard({Key? key, required this.onTap, required this.pudo, required this.onDelete, this.maxWidth = 100}) : super(key: key);

  @override
  State<PudoCard> createState() => _PudoCardState();
}

class _PudoCardState extends State<PudoCard> with TickerProviderStateMixin {
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

  void animateDelete(bool open) {
    final _zoomTween = Tween<double>(begin: deleteSize, end: open ? maxSize : 0);
    var controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
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

  @override
  Widget build(BuildContext context) => GestureDetector(
        onHorizontalDragStart: (DragStartDetails startDetails) {
          start = startDetails.localPosition;
        },
        onHorizontalDragEnd: (DragEndDetails endDetails) {
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
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimension.paddingS),
          child: Stack(children: [
            Transform.translate(
                offset: Offset(0 - getSafeOffset, 0),
                child: SizedBox(
                  height: 100,
                  child: PudoMapCard(
                    name: widget.pudo.businessName,
                    address: widget.pudo.label ?? "",
                    stars: (widget.pudo.rating?.stars ?? 0).toInt(),
                    image: widget.pudo.pudoPicId,
                    onTap: widget.onTap,
                    hasShadow: true,
                  ),
                )),
            Positioned(
              right: Dimension.padding,
              child: InkWell(
                onTap: () => SAAlertDialog.displayAlertWithButtons(
                    context, "Attenzione", "Sei sicuro di voler rimuovere questo pudo?\nSe continui non riceverai ulteriori notifiche per i pacchi non ancora consegnati", [
                  MaterialButton(
                    onPressed: null,
                    child: Text(
                      'Annulla',
                      style: Theme.of(context).textTheme.dialogButtonRefuse,
                    ),
                  ),
                  MaterialButton(
                      onPressed: widget.onDelete,
                      child: Text(
                        'OK',
                        style: Theme.of(context).textTheme.dialogButtonAccept,
                      )),
                ]),
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
