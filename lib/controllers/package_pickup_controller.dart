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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/commons/ui/optimized_cupertino_navigation_bar.dart';
import 'package:qui_green/commons/utilities/date_time_extension.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/models/pudo_package_event.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:share_plus/share_plus.dart';

class PackagePickupController extends StatefulWidget {
  const PackagePickupController({Key? key, required this.packageModel}) : super(key: key);
  final PudoPackage packageModel;

  @override
  _PackagePickupControllerState createState() => _PackagePickupControllerState();
}

class _PackagePickupControllerState extends State<PackagePickupController> {
  @override
  void initState() {
    super.initState();
  }

  void sharePackage() => Share.share(NetworkManager.instance.baseURL + "/api/v2/share/${widget.packageModel.shareLink ?? ""}");

  Widget _buildQr() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: Dimension.paddingL,
          ),
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                style: Theme.of(context).textTheme.navBarTitleDark,
                children: const [
                  TextSpan(
                    text: "Mostra questo QRCode\nal punto di ritiro ",
                  ),
                  TextSpan(text: "QuiGreen", style: TextStyle(color: AppColors.primaryColorDark)),
                ],
              )),
          const SizedBox(
            height: Dimension.padding,
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width / 2), boxShadow: Shadows.baseShadow),
            alignment: Alignment.center,
            child: QrImage(
              data: widget.packageModel.shareLink ?? "",
              version: QrVersions.auto,
              size: MediaQuery.of(context).size.width / 3,
            ),
            height: MediaQuery.of(context).size.width / 2,
            width: MediaQuery.of(context).size.width / 2,
          ),
          const SizedBox(
            height: Dimension.padding,
          ),
        ],
      );

  Widget _buildPhoto() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.boxGrey,
            padding: const EdgeInsets.symmetric(vertical: Dimension.paddingS, horizontal: Dimension.padding),
            child: Text(
              "FOTO DEL PACCO",
              style: Theme.of(context).textTheme.bodyTextBold,
            ),
          ),
          AspectRatio(
            aspectRatio: 18 / 9,
            child: CustomNetworkImage(
              url: widget.packageModel.packagePicId,
              fit: BoxFit.cover,
            ),
          )
        ],
      );

  String prettifyNotes(PudoPackageStatus? status, String? notes) {
    return convertStatus(status) + (notes != null ? " : " + notes : "");
  }

  String convertStatus(PudoPackageStatus? status) {
    switch (status) {
      case PudoPackageStatus.accepted:
        return "Accettato";
      case PudoPackageStatus.collected:
        return "Raccolto";
      case PudoPackageStatus.delivered:
        return "Consegnato";
      case PudoPackageStatus.notifySent:
        return "Utente notificato";
      case PudoPackageStatus.notified:
        return "Notificato";
      case PudoPackageStatus.expired:
        return "Scaduto";
      default:
        return "";
    }
  }

  Widget _buildEvents() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: AppColors.boxGrey,
          padding: const EdgeInsets.symmetric(vertical: Dimension.paddingS, horizontal: Dimension.padding),
          child: Text(
            "DETTAGLI PACCO",
            style: Theme.of(context).textTheme.bodyTextBold,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.packageModel.events?.length ?? 0,
          itemBuilder: (context, index) {
            PudoPackageEvent? event = widget.packageModel.events?[index];
            if (event != null) {
              return Padding(
                padding: const EdgeInsets.all(Dimension.paddingS),
                child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      text: '',
                      style: Theme.of(context).textTheme.bodyTextLight,
                      // style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      //       fontWeight: FontWeight.w300,
                      //       color: AppColors.primaryTextColor,
                      //     ),
                      children: [
                        TextSpan(
                          text: event.createTms?.ddmmyyyy,
                          style: Theme.of(context).textTheme.bodyTextBold,
                        ),
                        const TextSpan(
                          text: " - ",
                        ),
                        TextSpan(
                          text: prettifyNotes(event.packageStatus, event.notes),
                        ),
                      ],
                    )),
              );
            }
            return const SizedBox();
          },
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
          navigationBar: OptimizedCupertinoNavigationBar.build(
            context,
            middle: Text(
              'Ritiro del pacco',
              style: Theme.of(context).textTheme.navBarTitle,
            ),
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
            trailing: InkWell(
              onTap: sharePackage,
              child: Padding(
                padding: const EdgeInsets.only(right: Dimension.paddingS),
                child: SvgPicture.asset(
                  ImageSrc.shareArt,
                  width: 26,
                  height: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          //ClipPath is used to avoid the scrolling cards to go outside the screen
          //and being visible when popping the page
          child: ClipPath(
            child: SAScaffold(
                isLoading: NetworkManager.instance.networkActivity,
                body: ListView(
                  children: [
                    _buildQr(),
                    const SizedBox(
                      height: Dimension.paddingS,
                    ),
                    _buildPhoto(),
                    const SizedBox(
                      height: Dimension.paddingS,
                    ),
                    _buildEvents(),
                    const SizedBox(
                      height: Dimension.padding,
                    ),
                  ],
                )),
          )),
    );
  }
}
