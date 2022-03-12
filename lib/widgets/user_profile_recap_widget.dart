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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qui_green/commons/extensions/additional_button_styles.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/resources/res.dart';
import 'package:share_plus/share_plus.dart';

class UserProfileRecapWidget extends StatelessWidget {
  final int totalUsage;
  final String kgCO2Saved;
  final Function? onTap;
  final bool isForPudo;
  const UserProfileRecapWidget({Key? key, required this.totalUsage, required this.kgCO2Saved, this.onTap, this.isForPudo = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    text: '',
                    style: Theme.of(context).textTheme.bodyTextLight,
                    children: [
                      TextSpan(
                        text: (isForPudo ? 'recapPudoTitle' : 'recapUserTitle').localized(context),
                      ),
                      TextSpan(
                        text: "$totalUsage",
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      TextSpan(text: 'nTimes'.localized(context)),
                      TextSpan(text: 'contribute'.localized(context)),
                      TextSpan(
                        text: "$kgCO2Saved ",
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      TextSpan(text: 'co2Emission'.localized(context)),
                      WidgetSpan(
                        child: SvgPicture.asset(
                          ImageSrc.leaf,
                          width: 18,
                          height: 18,
                          color: AppColors.primaryColorDark,
                        ),
                      ),
                      const TextSpan(
                        text: ".",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              onTap?.call();
              _shareDidPress(context);
            },
            child: Text(
              'shareButton'.localized(context),
            ),
            style: AdditionalButtonStyles.simpleStyle(context),
          )
        ],
      ),
    );
  }

  _shareDidPress(BuildContext context) {
    var finalString = (isForPudo ? 'recapPudoTitle' : 'recapUserTitle').localized(context);
    finalString += '$totalUsage ${'nTimes'.localized(context)}${'contribute'.localized(context)}';
    finalString += '$kgCO2Saved ${'co2Emission'.localized(context)}.';
    finalString += '\n${'learnMore'.localized(context)}';
    Share.share(finalString);
  }
}
