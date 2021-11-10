//
//  UserProfileController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 03/07/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sabutton.dart';
import 'package:open_pudo/commons/sanetwork_image.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/main.dart';
import 'package:open_pudo/models/pudo_profile.dart';
import 'package:open_pudo/singletons/current_user.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/singletons/network.dart';
import 'package:provider/provider.dart';

class UserProfileController extends StatefulWidget {
  final String title;

  UserProfileController({Key? key, required this.title}) : super(key: key);

  @override
  _UserProfileControllerState createState() => _UserProfileControllerState();
}

class _UserProfileControllerState extends State<UserProfileController> {
  _editProfileDidPress() {
    Navigator.of(context).pushNamed('/editUserProfile');
  }

  _logoutDidPress() {
    NetworkManager().setAccessToken(null);
    Provider.of<CurrentUser>(context, listen: false).user = null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: true);

    return SAScaffold(
      isLoading: NetworkManager().networkActivity,
      appBar: AppBar(
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          "navTitle".localized(context, 'profileScreen'),
        ),
        actions: _currentUser.user != null
            ? [
                IconButton(
                  onPressed: () {
                    _editProfileDidPress();
                  },
                  icon: Icon(Icons.edit),
                )
              ]
            : null,
      ),
      body: _currentUser.user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SAButton(
                        label: 'accessHere'.localized(context, 'profileScreen'),
                        fixedSize: Size(140, 46),
                        borderRadius: 23,
                        onPressed: () {
                          needsLogin.value = true;
                        },
                      )
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: SANetworkImage(
                          url: _currentUser.user?.profilePicId,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: Column(
                        children: [
                          Text(
                            "${(_currentUser.user?.firstName ?? '')} ${(_currentUser.user?.lastName ?? '')}",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                      child: Card(
                        child: ListTile(
                          onTap: () {
                            if (_currentUser.user?.pudoOwner ?? false == true) {
                              NetworkManager().getMyPudoProfile().then(
                                (profile) {
                                  if (profile is PudoProfile) {
                                    Navigator.of(context, rootNavigator: false).pushNamed(
                                      '/myBusinessProfile',
                                      arguments: {"dataSource": profile},
                                    );
                                  }
                                },
                              ).catchError(
                                (onError) {
                                  SAAlertDialog.displayAlertWithClose(context, 'genericTitle'.localized(context, 'alert'), onError.toString());
                                },
                              );
                            } else {
                              Navigator.of(context, rootNavigator: false).pushNamed('/myPudos');
                            }
                          },
                          title: Text(
                            (_currentUser.user?.pudoOwner ?? false == true) ? "yourBusiness".localized(context, "profileScreen") : "yourPudos".localized(context, "profileScreen"),
                            style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 16),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios_sharp, size: 20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                      child: Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context, rootNavigator: false).pushNamed('/myPackages');
                          },
                          title: Text(
                            "yourShipment".localized(context, "profileScreen"),
                            style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 16),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios_sharp, size: 20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                      child: SAButton(
                          expanded: true,
                          fixedSize: Size.fromHeight(48),
                          backgroundColor: Colors.red[600],
                          label: "logout".localized(context, "profileScreen"),
                          onPressed: () {
                            _logoutDidPress();
                          },
                          borderRadius: 22.0),
                    )
                  ],
                ),
              ),
            ),
      bottomSheet: Container(
        color: Theme.of(context).backgroundColor,
        height: 102,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "OpenPUDO v${packageInfo.version}#${packageInfo.buildNumber}",
              style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
