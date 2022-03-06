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
  final dynamic title;
  final bool showTrailingChevron;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final Function()? onTap;
  final bool showTopDivider;
  final bool fullWidth;
  final double leadingWidth;

  const TableViewCell(
      {Key? key,
      this.leading,
      this.title,
      this.textAlign = TextAlign.left,
      this.textStyle,
      this.showTrailingChevron = true,
      this.onTap,
      this.showTopDivider = false,
      this.fullWidth = false,
      this.leadingWidth = 30})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: fullWidth ? EdgeInsets.zero : null,
      dense: true,
      onTap: onTap,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTopDivider)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Divider(
                height: 1,
              ),
            ),
          Padding(
            padding: fullWidth ? const EdgeInsets.symmetric(horizontal: Dimension.padding) : EdgeInsets.zero,
            child: Row(
              children: [
                leading != null
                    ? SizedBox(
                        width: leadingWidth,
                        child: leading,
                      )
                    : const SizedBox(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: title != null
                        ? title is String
                            ? Text(
                                title ?? "",
                                textAlign: textAlign,
                                style: (textStyle != null)
                                    ? textStyle
                                    : Theme.of(context).textTheme.bodyTextLight?.copyWith(
                                          color: AppColors.primaryTextColor,
                                        ),
                              )
                            : title is Widget
                                ? title
                                : const SizedBox()
                        : const SizedBox(),
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
