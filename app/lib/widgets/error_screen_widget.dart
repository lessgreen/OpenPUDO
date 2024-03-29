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
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/resources/res.dart';

class ErrorScreenWidget extends StatelessWidget {
  final String? description;
  const ErrorScreenWidget({
    Key? key,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            child: Column(
              children: [
                Flexible(
                  flex: 2,
                  child: Center(
                    child: Text(
                      description ?? 'unknownDescription'.localized(context, 'general'),
                      style: Theme.of(context).textTheme.bodyTextLight,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Flexible(
                  flex: 6,
                  child: Opacity(
                    opacity: 0.5,
                    child: SvgPicture.asset(ImageSrc.notFound),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
            width: constraints.maxWidth,
            height: constraints.maxHeight,
          ),
        );
      },
    );
  }
}
