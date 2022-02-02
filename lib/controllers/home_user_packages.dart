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
import 'package:provider/provider.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/listview_header.dart';
import 'package:qui_green/widgets/package_card.dart';

class HomeUserPackages extends StatefulWidget {
  const HomeUserPackages({Key? key}) : super(key: key);

  @override
  _HomeUserPackagesState createState() => _HomeUserPackagesState();
}

class _HomeUserPackagesState extends State<HomeUserPackages> with ConnectionAware {
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(builder: (_, currentUser, __) {
      return Material(
          child: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                padding: const EdgeInsetsDirectional.all(0),
                brightness: Brightness.dark,
                backgroundColor: AppColors.primaryColorDark,
                middle: Text(
                  'Home',
                  style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.account_circle_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pushNamed(Routes.profile),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Dimension.paddingS),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                      ),
                      child: const Text('Hai dei ritiri in attesa!'),
                    ),
                    Expanded(
                      child: ListViewHeader(
                          itemPadding: const EdgeInsets.only(bottom: Dimension.paddingS),
                          title: 'I tuoi pacchi:',
                          shrinkWrap: true,
                          itemCount: 10,
                          itemBuilder: (BuildContext context, int index) {
                            return PackageCard(
                              name: "Bar - La pinta",
                              address: "Via ippolito, 8",
                              stars: 3,
                              onTap: () => null,
                              isRead: false,
                              deliveryDate: '12/12/2021',
                              image: 'https://i0.wp.com/www.dailycal.org/assets/uploads/2021/04/package_gusler_cc-900x580.jpg',
                            );
                          }),
                    ),
                  ],
                ),
              )));
    });
  }
}
