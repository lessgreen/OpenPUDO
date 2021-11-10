//
//  MyPackagesController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 03/07/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/extensions/string_datetime.dart';
import 'package:open_pudo/models/pudo_package.dart';
import 'package:open_pudo/singletons/network.dart';

class MyPackagesController extends StatefulWidget {
  const MyPackagesController({Key? key}) : super(key: key);

  @override
  _MyPackagesControllerState createState() => _MyPackagesControllerState();
}

class _MyPackagesControllerState extends State<MyPackagesController> {
  List<PudoPackage> _dataSource = [];

  _refreshDataSource() {
    NetworkManager().getMyPackages().then((response) {
      if (response is List<PudoPackage>) {
        setState(() {
          _dataSource = response;
        });
      }
    }).catchError((onError) {
      SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, 'alert'), onError);
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshDataSource();
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
          "navTitle".localized(context, 'myPackagesScreen'),
        ),
      ),
      body: Container(
        child: _dataSource.length == 0
            ? Center(
                child: Text("packagesNotFound".localized(context, "myPackagesScreen")),
              )
            : ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: _dataSource.length,
                itemBuilder: (context, index) {
                  var aRow = _dataSource[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text("Last updated: ${aRow.updateTms?.formattedDate() ?? aRow.createTms?.formattedDate() ?? 'n/a'}", style: Theme.of(context).textTheme.caption),
                        subtitle: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Package ID: ",
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                Text(
                                  "${aRow.packageId}",
                                  style: Theme.of(context).textTheme.caption?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Status: ",
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                Text(
                                  "${aRow.events?.first.packageStatusRaw ?? '--'}",
                                  style: Theme.of(context).textTheme.caption?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios_sharp, size: 15),
                        onTap: () {
                          Navigator.of(context).pushNamed('/notificationDetails', arguments: {
                            'title': "Dettaglio Pacco",
                            'packageId': aRow.packageId,
                          });
                        },
                      ),
                      Divider(
                        thickness: 1,
                      )
                    ],
                  );
                }),
      ),
      isLoading: NetworkManager().networkActivity,
    );
  }
}
