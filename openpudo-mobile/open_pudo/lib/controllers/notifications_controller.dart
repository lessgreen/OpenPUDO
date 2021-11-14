//
//  NotificationsController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 30/08/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sabutton.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/main.dart';
import 'package:open_pudo/models/pudo_notification.dart';
import 'package:open_pudo/models/pudo_notification_data.dart';
import 'package:open_pudo/models/pudo_package_event.dart';
import 'package:open_pudo/singletons/current_user.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/singletons/network.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationsController extends StatefulWidget {
  NotificationsController({Key? key}) : super(key: key);

  @override
  _NotificationsControllerState createState() => _NotificationsControllerState();
}

class _NotificationsControllerState extends State<NotificationsController> {
  List<PudoNotification> _dataSource = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    NetworkManager().getMyNotifications().then(
      (value) {
        if (value is List<PudoNotification>) {
          setState(() {
            _dataSource = value;
            _refreshController.refreshCompleted();
          });
        }
      },
    ).catchError((onError) {
      SAAlertDialog.displayAlertWithClose(context, 'Error', onError);
      _refreshController.refreshFailed();
    });
  }

  _refreshNotifications() {
    NetworkManager().getMyNotifications().then(
      (value) {
        if (value is List<PudoNotification>) {
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
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: true);

    return FocusDetector(
      onFocusGained: () {
        _refreshNotifications();
      },
      child: SAScaffold(
        isLoading: NetworkManager().networkActivity,
        appBar: AppBar(
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
          ),
          title: Text(
            "navTitle".localized(context, 'notificationsScreen'),
          ),
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
            : SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: _dataSource.length,
                  itemBuilder: (context, index) {
                    var aRow = _dataSource[index];
                    PudoNotificationData? optData;
                    if (aRow.optData != null) {
                      optData = PudoNotificationData.fromJson(aRow.optData);
                    }
                    return Column(
                      children: [
                        ListTile(
                          title: Row(
                            children: [
                              Text(aRow.title ?? 'n/a'),
                              aRow.isRead == false
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                      child: Icon(Icons.circle, size: 12, color: Theme.of(context).primaryColor),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                            child: Text(aRow.message ?? 'n/a'),
                          ),
                          trailing: Container(
                            height: double.infinity,
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                            ),
                          ),
                          onTap: () {
                            if (aRow.isRead == false) {
                              NetworkManager().markNotificationAsRead(notificationId: aRow.notificationId).then(
                                (value) {
                                  Navigator.of(context).pushNamed('/notificationDetails', arguments: {'dataSource': aRow});
                                },
                              );
                              if (optData != null && optData.packageStatus == PudoPackageStatus.NOTIFY_SENT && optData.packageIdToInt != null) {
                                NetworkManager().changePackageStatus(packageId: optData.packageIdToInt!, newStatus: optData.packageStatus!);
                              }
                            } else {
                              Navigator.of(context).pushNamed('/notificationDetails', arguments: {'dataSource': aRow});
                            }
                          },
                        ),
                        Divider(
                          height: 1,
                        )
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
