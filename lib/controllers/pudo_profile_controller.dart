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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/table_view_cell.dart';
import 'package:qui_green/widgets/user_profile_recap_widget.dart';

class PudoProfileController extends StatefulWidget {
  const PudoProfileController({Key? key}) : super(key: key);

  @override
  _PudoProfileControllerState createState() => _PudoProfileControllerState();
}

class _PudoProfileControllerState extends State<PudoProfileController> with ConnectionAware {
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (_, currentUser, __) {
        return Material(
          child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBarFix.build(context,
                middle: Text(
                  'Il tuo profilo',
                  style: Theme.of(context).textTheme.navBarTitle,
                ),
                trailing: InkWell(
                  onTap: () => Navigator.pushNamed(context, Routes.profileEdit),
                  child: const Padding(
                    padding: EdgeInsets.only(right: Dimension.padding),
                    child: Icon(
                      CupertinoIcons.pencil_circle,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                )),
            child: ListView(
              children: [
                AspectRatio(aspectRatio: 18 / 9, child: CustomNetworkImage(fit: BoxFit.cover, url: currentUser.pudoProfile?.pudoPicId)),
                const SizedBox(
                  height: Dimension.paddingM,
                ),
                Center(
                  child: Text(
                    currentUser.pudoProfile?.businessName ?? " ",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Utente dal ${currentUser.pudoProfile?.createTms != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(currentUser.pudoProfile!.createTms!)) : " "}',
                    style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: AppColors.primaryTextColor),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const UserProfileRecapWidget(
                  totalUsage: 123,
                  kgCO2Saved: 456,
                  isForPudo: true,
                ),
                TableViewCell(
                    showTopDivider: true,
                    fullWidth: true,
                    leading: const Icon(
                      CupertinoIcons.person_fill,
                      color: AppColors.primaryColorDark,
                      size: 26,
                    ),
                    title: "I tuoi utenti",
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.pudoUsersList);
                    }),
                TableViewCell(
                  leading: SvgPicture.asset(
                    ImageSrc.logoutIcon,
                    color: AppColors.cardColor,
                    width: 36,
                    height: 36,
                  ),
                  title: "Logout",
                  onTap: () {
                    Navigator.pop(context);
                    NetworkManager.instance.setAccessToken(null);
                    currentUser.refresh();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
