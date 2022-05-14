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
import 'package:qui_green/resources/res.dart';

class TextFieldButton extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  final Function() onPressed;
  final Color textColor;

  const TextFieldButton({
    Key? key,
    required this.text,
    this.padding = EdgeInsets.zero,
    required this.onPressed,
    this.textColor = AppColors.primaryColorDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => TextButton(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: textColor),
        ),
        style: Theme.of(context).textButtonTheme.style?.copyWith(
            padding: MaterialStateProperty.all(padding),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder(side: BorderSide.none))),
        onPressed: onPressed,
      );
}
