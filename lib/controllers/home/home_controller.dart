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
import 'package:qui_green/controllers/home/widgets/package_card.dart';
import 'package:qui_green/controllers/home_pudo/home_pudo_controller.dart';
import 'package:qui_green/controllers/profile/profile_controller.dart';
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
                          backgroundColor: AppColors.primaryColorDark,
                          middle: Text(
                            'Home',
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.copyWith(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.account_circle_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                Navigator.of(context).pushNamed(Routes.profile),
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
                                padding: const EdgeInsets.only(
                                    left: Dimension.padding),
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return PackageCard(
                                      name: "Bar - La pinta",
                                      address: "Via ippolito, 8",
                                      stars: 3,
                                      onTap: () => null,
                                      isRead: false,
                                      deliveryDate: '12/12/2021',
                                      image:
                                          'https://i0.wp.com/www.dailycal.org/assets/uploads/2021/04/package_gusler_cc-900x580.jpg',
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
