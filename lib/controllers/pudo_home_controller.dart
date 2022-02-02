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
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/resources/res.dart';

class PudoHomeController extends StatefulWidget {
  const PudoHomeController({Key? key}) : super(key: key);

  @override
  _PudoHomeControllerState createState() => _PudoHomeControllerState();
}

class _PudoHomeControllerState extends State<PudoHomeController> with ConnectionAware {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home)),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded)),
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
                        backgroundColor: AppColors.primaryColorDark,
                        middle: Text(
                          'Il tuo profilo',
                          style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white),
                        ),
                      ),
                      child: Container(),
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
                            'HomePudo',
                            style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white),
                          ),
                        ),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              NetworkManager.instance.setAccessToken(null);
                              Provider.of<CurrentUser>(context, listen: false).refresh();
                            },
                            child: const Text("Logout"),
                          ),
                        ));
                  },
                },
              );
          }
        },
      ),
    );
  }
}
