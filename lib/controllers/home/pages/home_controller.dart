//
//  home_controller.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.

// ignore_for_file: unused_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/widgets/base_page.dart';
import 'package:qui_green/controllers/home/viewmodel/home_controller_viewmodel.dart';
import 'package:qui_green/controllers/profile/pages/profile_controller.dart';
import 'package:qui_green/models/page_type.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

class HomeController extends StatefulWidget {
  const HomeController({Key? key}) : super(key: key);

  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider0<HomeControllerViewModel?>(
            create: (context) => HomeControllerViewModel(),
            update: (context, viewModel) => viewModel),
      ],
      child: Consumer<HomeControllerViewModel>(builder: (_, viewModel, __) {
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
                            backgroundColor: AppColors.primaryColorDark,
                            middle: Text(
                              'Pudo',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          child: const Center(
                            child: Text("Pudo"),
                          ),
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
                              backgroundColor: AppColors.primaryColorDark,
                              middle: Text(
                                'Home',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(color: Colors.white),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.account_circle_rounded,color: Colors.white,),
                                onPressed: ()=>Navigator.of(context).pushNamed(Routes.profile),
                              ),
                            ),
                            child: const Center(
                              child: Text("Home"),
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
      }),
    );
  }
}
