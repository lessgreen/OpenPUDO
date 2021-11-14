//
//  MyPudosController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 03/07/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/models/pudo_profile.dart';
import 'package:open_pudo/singletons/network.dart';

class MyPudosController extends StatefulWidget {
  const MyPudosController({Key? key}) : super(key: key);

  @override
  _MyPudosControllerState createState() => _MyPudosControllerState();
}

class _MyPudosControllerState extends State<MyPudosController> {
  List<PudoProfile> _dataSource = [];

  _refreshDataSource() {
    NetworkManager().getMyPudos().then((response) {
      if (response is List<PudoProfile>) {
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
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        _refreshDataSource();
      },
      child: SAScaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
          ),
          title: Text(
            "navTitle".localized(context, 'myPudosScreen'),
          ),
        ),
        body: Container(
          child: _dataSource.length == 0
              ? Center(
                  child: Text("pudosNotFound".localized(context, "myPudosScreen")),
                )
              : ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: _dataSource.length,
                  itemBuilder: (context, index) {
                    var aRow = _dataSource[index];
                    return Column(
                      children: [
                        Dismissible(
                          key: Key(aRow.businessName),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            NetworkManager().removePudoFavorite(aRow.pudoId.toString()).then(
                              (results) {
                                setState(() {
                                  _dataSource = results;
                                });
                              },
                            ).catchError(
                              (onError) => SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, 'alert'), onError),
                            );
                          },
                          background: Container(
                            color: Colors.red[600],
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                child: Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed('/publicPudoProfile', arguments: {"dataSource": aRow});
                            },
                            title: Text("${aRow.businessName}"),
                            trailing: Icon(Icons.arrow_forward_ios_sharp, size: 15),
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                        )
                      ],
                    );
                  }),
        ),
        isLoading: NetworkManager().networkActivity,
      ),
    );
  }
}
