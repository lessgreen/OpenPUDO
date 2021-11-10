//
//  HomeController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 23/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:open_pudo/controllers/pudo_map_controller.dart';
import 'package:open_pudo/controllers/routes.dart';
import 'package:open_pudo/controllers/user_profile_controller.dart';
import 'package:open_pudo/models/base_response.dart';
import 'package:open_pudo/models/pudo_notification_data.dart';
import 'package:open_pudo/models/pudo_package_event.dart';
import 'package:open_pudo/singletons/current_user.dart';
import 'package:open_pudo/singletons/network.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class HomeController extends StatefulWidget {
  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  int _oldSelectedIndex = 0;
  List<NavigatorObserver> _navigatorStateArray = [];

  void _handleMessage(RemoteMessage message) {
    print(message);
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        if (message != null) {
          _handleMessage(message);
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      NetworkManager().getNotificationsCount().then((value) {
        if (value is OPBaseResponse) {
          badgeCounter.value = value.payload.toInt();
        }
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleOptionalData(message);
    });

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if ((sharedPreferences?.getBool('introShown') ?? false) == false) {
        Navigator.of(context, rootNavigator: false).pushNamed('/onboarding');
      }
    });

    needsLogin.addListener(() {
      if (needsLogin.value == true) {
        Navigator.of(context, rootNavigator: false).pushNamed('/login');
      }
    });

    // FIXME: This seems to be responsible of twice call to refresh token.
    // if (sharedPreferences?.getString('accessToken') != null) {
    //   var oldToken = sharedPreferences?.getString('accessToken');
    //   NetworkManager().renewToken(accessToken: oldToken!).then((response) {
    //     print(response);
    //   }).catchError((onError) {
    //     SAAlertDialog.displayAlertWithClose(context, 'Error', onError.toString());
    //   });
    // }

    _navigatorStateArray.add(NavigatorObserver());
    _navigatorStateArray.add(NavigatorObserver());
  }

  void _handleOptionalData(RemoteMessage message) {
    PudoNotificationData? notificationData = PudoNotificationData.fromJson(message.data);

    if (notificationData.notificationIdToInt != null) {
      NetworkManager().markNotificationAsRead(notificationId: notificationData.notificationIdToInt!).then(
        (value) {
          Navigator.of(context).pushNamed('/notificationDetails', arguments: {'optData': notificationData});
        },
      );
    }
    if (notificationData.packageStatus == PudoPackageStatus.NOTIFY_SENT && notificationData.packageIdToInt != null) {
      NetworkManager().changePackageStatus(packageId: notificationData.packageIdToInt!, newStatus: notificationData.packageStatus!);
    }
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: true);
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        onTap: (selectedIndex) {
          switch (selectedIndex) {
            case 0:
              print("current route name: /map");
              currentRouteName = '/map';
              break;
            case 1:
              print("current route name: /profile");
              currentRouteName = '/profile';
              break;
          }
          if (selectedIndex == _oldSelectedIndex) {
            _navigatorStateArray[selectedIndex].navigator?.popUntil((Route<dynamic> r) => r.isFirst);
          }
          _oldSelectedIndex = selectedIndex;
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        late final CupertinoTabView returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(
              builder: (context) {
                return FocusDetector(
                  onFocusGained: () {
                    if (_currentUser.user != null || _currentUser.pudoProfile != null) {
                      NetworkManager().getNotificationsCount().then((value) {
                        if (value is OPBaseResponse) {
                          badgeCounter.value = value.payload.toInt();
                        }
                      });
                    }
                  },
                  child: CupertinoPageScaffold(
                    child: PudoMapController(),
                  ),
                );
              },
              navigatorObservers: [_navigatorStateArray[0]],
              onGenerateRoute: ((RouteSettings settings) {
                return routeWithSetting(settings);
              }),
            );
            break;
          case 1:
            returnValue = CupertinoTabView(
              builder: (context) {
                return CupertinoPageScaffold(
                  child: UserProfileController(
                    title: "Profile",
                  ),
                );
              },
              navigatorObservers: [_navigatorStateArray[1]],
              onGenerateRoute: ((RouteSettings settings) {
                return routeWithSetting(settings);
              }),
            );
            break;
        }
        return returnValue;
      },
    );
  }
}
