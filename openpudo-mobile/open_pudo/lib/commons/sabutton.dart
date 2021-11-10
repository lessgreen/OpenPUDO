//
//  SAButton.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/07/2021.
//  Copyright © 2021 Sofapps. All rights reserved.

import 'package:flutter/material.dart';

class SAButton extends StatelessWidget {
  final Function()? onPressed;
  final double? borderRadius;
  final Color? backgroundColor;
  final Size? fixedSize;
  final String? label;
  final bool? expanded;
  const SAButton({Key? key, this.label, this.onPressed, this.expanded, this.borderRadius, this.fixedSize, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var innerButton = ElevatedButton(
      child: Text(
        label ?? "Label",
        style: Theme.of(context).textTheme.button?.copyWith(color: Theme.of(context).primaryTextTheme.bodyText1?.color),
      ),
      onPressed: onPressed,
      style: ButtonStyle(
        fixedSize: fixedSize != null ? MaterialStateProperty.all<Size>(fixedSize!) : null,
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor ?? Theme.of(context).primaryColor),
        shape: borderRadius != null
            ? MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius!),
                  side: BorderSide(color: backgroundColor ?? Theme.of(context).primaryColor),
                ),
              )
            : null,
      ),
    );

    return expanded == true
        ? Row(
            children: [
              Expanded(
                child: innerButton,
              ),
            ],
          )
        : innerButton;
  }
}
