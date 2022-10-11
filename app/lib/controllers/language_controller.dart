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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/widgets/table_view_cell.dart';

class LanguageController extends StatefulWidget {
  const LanguageController({Key? key}) : super(key: key);

  @override
  State<LanguageController> createState() => _LanguageControllerState();
}

class _LanguageControllerState extends State<LanguageController> with ConnectionAware {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (_, currentUser, __) {
        return FocusDetector(
          onVisibilityGained: () {},
          child: SAScaffold(
            isLoading: NetworkManager.instance.networkActivity,
            cupertinoBar: CupertinoNavigationBarFix.build(
              context,
              middle: Text(
                'navTitle'.localized(context),
                style: Theme.of(context).textTheme.navBarTitle,
              ),
              leading: CupertinoNavigationBarBackButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Stack(
              alignment: Alignment.center,
              children: [
                ListView(
                  controller: _scrollController,
                  children: [
                    const SizedBox(height: 20),
                    TableViewCell(
                      showTrailingChevron: false,
                      leading: SvgPicture.asset(
                        ImageSrc.en,
                        width: 36,
                        height: 40,
                      ),
                      title: 'englishTitle'.localized(context),
                      trailing: Visibility(
                        visible: currentUser.language != "it",
                        child: SvgPicture.asset(
                          ImageSrc.checkMark,
                          color: Theme.of(context).primaryColor,
                          width: 18,
                          height: 18,
                        ),
                      ),
                      onTap: () {
                        currentUser.language = 'en';
                      },
                    ),
                    TableViewCell(
                      showTrailingChevron: false,
                      leading: SvgPicture.asset(
                        ImageSrc.it,
                        width: 36,
                        height: 40,
                      ),
                      title: 'italianTitle'.localized(context),
                      trailing: Visibility(
                        visible: currentUser.language == "it",
                        child: SvgPicture.asset(
                          ImageSrc.checkMark,
                          color: Theme.of(context).primaryColor,
                          width: 18,
                          height: 18,
                        ),
                      ),
                      onTap: () {
                        currentUser.language = 'it';
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
