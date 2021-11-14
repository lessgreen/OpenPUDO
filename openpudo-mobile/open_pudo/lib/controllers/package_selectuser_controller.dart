//
//  PackageSelectUserController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/09/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/models/user_profile.dart';
import 'package:open_pudo/singletons/network.dart';

class PackageSelectUserController extends StatefulWidget {
  const PackageSelectUserController({Key? key}) : super(key: key);

  @override
  _PackageSelectUserControllerState createState() => _PackageSelectUserControllerState();
}

class _PackageSelectUserControllerState extends State<PackageSelectUserController> {
  List<UserProfile> _dataSource = [];

  @override
  void initState() {
    super.initState();
    _refreshDataSource();
  }

  _refreshDataSource() {
    NetworkManager().getMyPudoUsers().then(
      (value) {
        if (value is List<UserProfile>) {
          setState(() {
            _dataSource = value;
          });
        }
      },
    ).catchError((onError) {
      SAAlertDialog.displayAlertWithClose(context, 'Error', onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SAScaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          "selectUser".localized(context, 'updatePackageScreen'),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
              itemCount: _dataSource.length,
              itemBuilder: (context, index) {
                var aRow = _dataSource[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text('${aRow.firstName} ${aRow.lastName}'),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 15),
                      onTap: () {
                        Navigator.of(context).pop(aRow);
                      },
                    ),
                    Divider(
                      height: 1,
                    )
                  ],
                );
              }),
        ),
      ),
      isLoading: NetworkManager().networkActivity,
    );
  }
}
