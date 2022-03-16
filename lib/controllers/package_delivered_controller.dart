/*
 OpenPUDO - PUDO and Micro-delivery software for Last Mile Collaboration
 Copyright (C) 2020-2022 LESS SRL - https://less.green

 This file is part of OpenPUDO software.

 OpenPUDO is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License version 3
 as published by the Copyright Owner.

 OpenPUDO is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License version 3 for more details.

 You should have received a copy of the GNU Affero General Public License
 version 3 published by the Copyright Owner along with OpenPUDO.
 If not, see <https://github.com/lessgreen/OpenPUDO>.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/flutter_qr_bar_scanner.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/widgets/table_view_cell.dart';

class PackageDeliveredController extends StatefulWidget {
  const PackageDeliveredController({Key? key}) : super(key: key);

  @override
  _PackageDeliveredControllerState createState() => _PackageDeliveredControllerState();
}

class _PackageDeliveredControllerState extends State<PackageDeliveredController> {
  PackageSummary? selectedPackage;
  String? _code;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBarFix.build(
            context,
            middle: Text(
              'navTitle'.localized(context),
              style: Theme.of(context).textTheme.navBarTitle,
            ),
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          child: SAScaffold(
            isLoading: NetworkManager.instance.networkActivity,
            body: ListView(
              children: [
                const SizedBox(
                  height: Dimension.padding,
                ),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: '',
                      style: Theme.of(context).textTheme.navBarTitleDark,
                      children: [
                        TextSpan(
                          text: 'mainLabel'.localized(context),
                        ),
                        TextSpan(
                          text: "${'defaultTitle'.localized(context, 'general')}\n",
                          style: const TextStyle(color: AppColors.primaryColorDark, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: 'secondaryLabel'.localized(context),
                        ),
                      ],
                    )),
                const SizedBox(
                  height: Dimension.padding,
                ),
                Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 10 * 8, maxHeight: MediaQuery.of(context).size.width / 10 * 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimension.borderRadius),
                      border: Border.all(color: AppColors.colorGrey, width: 2),
                      color: AppColors.colorGrey,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimension.borderRadius),
                      child: QRBarScannerCamera(
                        qrCodeCallback: _handleQRCode,
                        formats: const [BarcodeFormats.QR_CODE],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: Dimension.paddingM,
                ),
                Text(
                  'orLabel'.localized(context),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyTextItalicSecondary,
                ),
                const SizedBox(
                  height: Dimension.paddingXS,
                ),
                TableViewCell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.packagesList).then((value) {
                      if (value != null && value is PackageSummary) {
                        setState(() {
                          selectedPackage = value;
                        });
                        NetworkManager.instance.changePackageStatus(packageId: value.packageId, newStatus: PackageStatus.collected).then((value) {
                          if (value is PudoPackage) {
                            Navigator.of(context).pop();
                          }
                        });
                      }
                    });
                  },
                  fullWidth: true,
                  showTopDivider: true,
                  showTrailingChevron: true,
                  title: selectedPackage == null ? 'waitingShipmentLabel'.localized(context) : selectedPackage!.packageName ?? "",
                  leading: SvgPicture.asset(
                    ImageSrc.boxFillIcon,
                    color: AppColors.primaryColorDark,
                    height: 36,
                    width: 36,
                  ),
                ),
              ],
            ),
          )),
    );
  }

  void _handleQRCode(String? code) {
    if (_code == null && code != null) {
      _code = code;
      NetworkManager.instance.getPackageDetailsByQrCode(shareLink: _code!).then((value) {
        if (value is PudoPackage) {
          NetworkManager.instance.changePackageStatus(packageId: value.packageId, newStatus: PackageStatus.collected).then((value) {
            if (value is PudoPackage) {
              Navigator.of(context).pop();
            } else {
              SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), value, barrierDismissable: false, completion: () => _code = null);
            }
          }).catchError((onError) {
            SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError, barrierDismissable: false, completion: () => _code = null);
          });
        } else {
          SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), value, barrierDismissable: false, completion: () => _code = null);
        }
      }).catchError((onError) {
        SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError, barrierDismissable: false, completion: () => _code = null);
      });
    }
  }
}
