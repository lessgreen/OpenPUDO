//
//  NotificationDetailsController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 31/08/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/extensions/string_datetime.dart';
import 'package:open_pudo/models/pudo_notification.dart';
import 'package:open_pudo/models/pudo_notification_data.dart';
import 'package:open_pudo/models/pudo_package.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/singletons/network.dart';

class NotificationDetailsController extends StatefulWidget {
  final dynamic arguments;
  NotificationDetailsController({Key? key, this.arguments}) : super(key: key);

  @override
  _NotificationDetailsControllerState createState() => _NotificationDetailsControllerState();
}

class _NotificationDetailsControllerState extends State<NotificationDetailsController> {
  PudoNotification? _dataSource;
  PudoPackage? _packageInfo;
  PudoNotificationData? _optData;
  String? _title;
  int? _packageId;

  @override
  void initState() {
    super.initState();

    if (widget.arguments != null && widget.arguments is Map<String, dynamic>) {
      Map<String, dynamic> infoDict = widget.arguments;
      if (infoDict.containsKey("dataSource")) {
        _dataSource = infoDict["dataSource"];
        if (_dataSource != null && _dataSource!.optData != null) {
          _optData = PudoNotificationData.fromJson(_dataSource!.optData);
        }
      }
      if (infoDict.containsKey("optData")) {
        _optData = infoDict["optData"];
      }
      if (infoDict.containsKey("title")) {
        _title = infoDict["title"];
      }
      if (infoDict.containsKey("packageId")) {
        _packageId = infoDict["packageId"];
      }
    }
    _refreshDataSource();
  }

  _refreshDataSource() {
    int? tmpPackageId;

    if (_optData != null && _optData!.packageIdToInt != null) {
      tmpPackageId = _optData!.packageIdToInt;
    } else if (_packageId != null) {
      tmpPackageId = _packageId;
    }
    if (tmpPackageId != null) {
      NetworkManager().getPackageDetails(packageId: tmpPackageId).then(
        (response) {
          if (response != null && response is PudoPackage) {
            setState(() {
              _packageInfo = response;
            });
          }
        },
      ).catchError((onError) {
        SAAlertDialog.displayAlertWithClose(context, 'Error', onError);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SAScaffold(
      isLoading: NetworkManager().networkActivity,
      appBar: AppBar(
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          _title ?? "navTitle".localized(context, 'notificationDetailsScreen'),
        ),
      ),
      body: _dataSource == null && _packageInfo == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ops!, si è verificato un errore.',
                      )
                    ],
                  ),
                ],
              ),
            )
          : ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                (_dataSource != null)
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _dataSource?.createTms?.formattedDate() ?? 'n/a',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _dataSource?.title ?? '--',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _dataSource?.message ?? '--',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
                (_packageInfo != null && _packageInfo!.events != null && _packageInfo!.events!.length > 0)
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                            child: Text('Lista eventi'),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _packageInfo!.events!.length,
                            itemBuilder: (context, index) {
                              var aRow = _packageInfo!.events![index];
                              return Column(
                                children: [
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Text(
                                          aRow.createTms?.formattedDate() ?? 'n/a',
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Spacer(),
                                        Text(
                                          aRow.packageStatusRaw ?? 'n/a',
                                          style: Theme.of(context).textTheme.caption?.copyWith(fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    subtitle: Text(aRow.notes ?? '--'),
                                  ),
                                  Divider(
                                    height: 1,
                                  )
                                ],
                              );
                            },
                          ),
                        ],
                      )
                    : SizedBox()
              ],
            ),
    );
  }
}
