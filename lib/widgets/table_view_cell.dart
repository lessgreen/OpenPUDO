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
import 'package:qui_green/resources/res.dart';

class TableViewCell extends StatelessWidget {
  final Widget? leading;
  final String? title;
  final bool showTrailingChevron;
  final Function? onTap;

  const TableViewCell({
    Key? key,
    this.leading,
    this.title,
    this.showTrailingChevron = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: () => onTap?.call(),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              leading != null
                  ? SizedBox(
                      width: 30,
                      child: leading,
                    )
                  : const SizedBox(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title ?? "",
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyTextLight?.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                  ),
                ),
              ),
              showTrailingChevron
                  ? SvgPicture.asset(
                      ImageSrc.chevronRight,
                      width: 24,
                      height: 24,
                      color: AppColors.colorGrey,
                    )
                  : const SizedBox(),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Divider(
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
