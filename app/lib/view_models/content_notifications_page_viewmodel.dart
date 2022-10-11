import 'package:flutter/cupertino.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/commons/utilities/print_helper.dart';
import 'package:qui_green/models/base_response.dart';
import 'package:qui_green/models/openpudo_notification.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class ContentNotificationsPageViewModel with ChangeNotifier {
  BuildContext context;

  ContentNotificationsPageViewModel(this.context) {
    _fetchNotifications().then(
      (response) {
        if (response is List<OpenPudoNotification>) {
          _availableNotifications = response;
          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  final ScrollController scrollController = ScrollController();
  bool _canFetchMore = true;
  final int _fetchLimit = 20;
  List<OpenPudoNotification> _availableNotifications = [];
  String? errorDescription;

  List<OpenPudoNotification> get availableNotifications => _availableNotifications;

  refreshDidTriggered() {
    _availableNotifications.clear();
    notifyListeners();
    _fetchNotifications().then(
      (response) {
        if (response is List<OpenPudoNotification>) {
          _availableNotifications = response;
          notifyListeners();
        }
      },
    );
  }

  Future<dynamic> _fetchNotifications({bool? appendMode = false}) {
    errorDescription = null;
    notifyListeners();
    return NetworkManager.instance.getNotifications(limit: _fetchLimit, offset: _availableNotifications.length).then((response) {
      if (response is List<OpenPudoNotification>) {
        _canFetchMore = (response.length == _fetchLimit);
        if (!scrollController.hasListeners) {
          scrollController.addListener(_scrollListener);
        }
      } else if (appendMode == false) {
        if (response is ErrorDescription) {
          errorDescription = HtmlUnescape().convert(response.value.first.toString());
          notifyListeners();
        } else {
          errorDescription = 'unknownDescription'.localized(context, 'general');
          notifyListeners();
        }
      }
      return response;
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError));
  }

  onNotificationDelete(OpenPudoNotification notification) async {
    NetworkManager.instance.deleteNotification(notificationId: notification.notificationId).then((value) {
      if (value is OPBaseResponse) {
        _availableNotifications.removeWhere((element) => element.notificationId == notification.notificationId);
        Provider.of<CurrentUser>(context, listen: false).unreadNotifications--;
        notifyListeners();
      } else {
        ///Show error
      }
    }).catchError((onError) {
      safePrint(onError);
    });
  }

  onNotificationTile(OpenPudoNotification notification) async {
    if (!notification.isRead) {
      NetworkManager.instance.markNotificationAsRead(notificationId: notification.notificationId).then((value) {
        if (value is OPBaseResponse) {
          int index = _availableNotifications.indexWhere((element) => element.notificationId == notification.notificationId);
          if (index > -1) {
            _availableNotifications[index] = notification.copyWith(readTms: DateTime.now());
            Provider.of<CurrentUser>(context, listen: false).unreadNotifications--;
            notifyListeners();
          }
        }
      });
    }
    _handleNotificationRouting(notification);
  }

  void _handleNotificationRouting(OpenPudoNotification notification) {
    if (notification.optData != null) {
      if (notification.optData!.notificationType == NotificationType.package) {
        if (notification.optData!.packageId != null) {
          _handlePackageRouting(context, int.parse(notification.optData!.packageId!));
        }
      } else if (notification.optData!.notificationType == NotificationType.favourite) {
        if (notification.optData!.userId != null) {
          _handleUserRouting(context, int.parse(notification.optData!.userId!));
        }
      }
    }
  }

  void _handlePackageRouting(BuildContext context, int packageId) {
    NetworkManager.instance.getPackageDetails(packageId: packageId).then(
      (response) async {
        if (response is PudoPackage) {
          if (response.packageStatus == PackageStatus.notifySent) {
            await NetworkManager.instance.changePackageStatus(packageId: response.packageId, newStatus: PackageStatus.notified).then((value) {
              if (value is PudoPackage) {
                Navigator.of(context).pushNamed(Routes.packagePickup, arguments: value).then(
                      (value) => Provider.of<CurrentUser>(context, listen: false).triggerReload(),
                    );
              } else {
                SAAlertDialog.displayAlertWithClose(context, "genericErrorTitle".localized(context, 'general'), value, barrierDismissable: false);
              }
            }).catchError((onError) {
              SAAlertDialog.displayAlertWithClose(context, "genericErrorTitle".localized(context, 'general'), onError, barrierDismissable: false);
            });
          } else {
            Navigator.of(context).pushNamed(Routes.packagePickup, arguments: response).then((value) => Provider.of<CurrentUser>(context, listen: false).triggerReload());
          }
        } else {
          SAAlertDialog.displayAlertWithClose(context, "genericErrorTitle".localized(context, 'general'), "genericErrorDescription".localized(context, 'general'));
        }
      },
    ).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "genericErrorTitle".localized(context, 'general'), onError));
  }

  void _handleUserRouting(BuildContext context, int userId) {
    NetworkManager.instance.getUserProfile(userId: userId).then(
      (response) async {
        if (response is UserProfile) {
          Navigator.of(context).pushNamed(Routes.userDetail, arguments: response);
        } else {
          SAAlertDialog.displayAlertWithClose(context, "genericErrorTitle".localized(context, 'general'), "genericErrorDescription".localized(context, 'general'));
        }
      },
    ).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "genericErrorTitle".localized(context, 'general'), onError));
  }

  void _scrollListener() {
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels != 0 && !NetworkManager.instance.networkActivity.value && _canFetchMore) {
        _fetchNotifications(appendMode: true).then(
          (response) {
            if (response is List<OpenPudoNotification>) {
              _availableNotifications.addAll(response);
              notifyListeners();
            }
          },
        );
      }
    }
  }
}
