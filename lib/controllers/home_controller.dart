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

// ignore_for_file: unused_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/package_card.dart';
import 'package:qui_green/controllers/home_pudo_controller.dart';
import 'package:qui_green/controllers/profile_controller.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

class HomeController extends StatefulWidget {
  const HomeController({Key? key}) : super(key: key);

  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> with ConnectionAware{
  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home)),
            BottomNavigationBarItem(icon: Icon(Icons.map)),
          ],
        ),
        tabBuilder: (innerContext, index) {
          switch (index) {
            case 1:
              return CupertinoTabView(
                routes: {
                  '/': (context) {
                    return CupertinoPageScaffold(
                      navigationBar: CupertinoNavigationBar(
                        padding: const EdgeInsetsDirectional.all(0),
                        brightness: Brightness.dark,
                        backgroundColor: AppColors.primaryColorDark,
                        middle: Text(
                          'Pudo',
                          style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white),
                        ),
                      ),
                      child: const HomePudoController(),
                    );
                  },
                },
              );
            default:
              return CupertinoTabView(
                routes: {
                  '/': (context) {
                    return CupertinoPageScaffold(
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
                            const SizedBox(height: 20),
                            Container(
                                padding: const EdgeInsets.only(left: Dimension.padding),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'I tuoi pacchi:',
                                  style: TextStyle(color: Colors.grey.shade800),
                                )),
                            Container(
                              height: 20,
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: 1,
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
                        ));
                  },
                  '/profile': (context) {
                    return const ProfileController();
                  },
                },
              );
          }
        },
      ),
    );
  }
}
