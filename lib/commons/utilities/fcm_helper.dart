import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

Future<void> firebaseMessagingHandler(BuildContext context, RemoteMessage? message) async {
  if (message != null) {
    if (message.data.containsKey("packageId")) {
      handlePackageRouting(context, int.parse(message.data['packageId']));
    }
  }
}

Future<void> firebaseMessagingOpenedAppHandler(BuildContext context, RemoteMessage? message) async {
  if (message != null) {
    ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
      backgroundColor: const Color.fromRGBO(254, 227, 183, 1),
      content: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).clearMaterialBanners();
            if (message.data.containsKey("packageId")) {
              handlePackageRouting(context, int.parse(message.data['packageId']));
            }
          },
          child: Text(message.notification?.body ?? "")),
      actions: const [SizedBox()],
      onVisible: () {
        Future.delayed(const Duration(seconds: 6), () {
          ScaffoldMessenger.of(context).clearMaterialBanners();
        });
      },
    ));
  }
}

void handlePackageRouting(BuildContext context, int packageId) {
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
              SAAlertDialog.displayAlertWithClose(context, "Error", value, barrierDismissable: false);
            }
          }).catchError((onError) {
            SAAlertDialog.displayAlertWithClose(context, "Error", onError, barrierDismissable: false);
          });
        } else {
          Navigator.of(context).pushNamed(Routes.packagePickup, arguments: response).then((value) => Provider.of<CurrentUser>(context, listen: false).triggerReload());
        }
      } else {
        SAAlertDialog.displayAlertWithClose(context, "Error", "Ops!, Qualcosa e' andato storto");
      }
    },
  ).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
}
