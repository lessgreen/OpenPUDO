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
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/commons/utilities/date_time_extension.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/models/pudo_package_event.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:share_plus/share_plus.dart';

class PackagePickupController extends StatefulWidget {
  const PackagePickupController({Key? key, required this.packageModel, this.isForPudo = false}) : super(key: key);
  final PudoPackage packageModel;
  final bool isForPudo;

  @override
  _PackagePickupControllerState createState() => _PackagePickupControllerState();
}

class _PackagePickupControllerState extends State<PackagePickupController> {
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
            widget.isForPudo ? 'Dettagli pacco' : 'Ritiro del pacco',
            style: Theme.of(context).textTheme.navBarTitle,
          ),
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          trailing: !widget.isForPudo
              ? InkWell(
                  onTap: _sharePackage,
                  child: Padding(
                    padding: const EdgeInsets.only(right: Dimension.paddingS),
                    child: SvgPicture.asset(
                      ImageSrc.shareArt,
                      width: 26,
                      height: 26,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
        child: SAScaffold(
          isLoading: NetworkManager.instance.networkActivity,
          body: ListView(
            children: [
              if (!widget.isForPudo) _buildQr(),
              if (!widget.isForPudo)
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
          ),
        ),
      ),
    );
  }

  //MARK: Actions
  void _sharePackage() {
    if (widget.packageModel.shareLink != null) {
      Share.share(NetworkManager.instance.baseURL + "/api/v2/share/${widget.packageModel.shareLink!}");
    } else {
      SAAlertDialog.displayAlertWithClose(context, 'Attenzione', 'Si è verificato un problema con la condivisione. Per favore, riprova.');
    }
  }

  //MARK: Build widget accessories

  Widget _buildQr() {
    return Column(
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
  }

  Widget _buildPhoto() {
    return Column(
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
  }

  Widget _buildEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: AppColors.boxGrey,
          padding: const EdgeInsets.symmetric(vertical: Dimension.paddingS, horizontal: Dimension.padding),
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              text: 'DETTAGLI PACCO',
              style: widget.isForPudo ? Theme.of(context).textTheme.bodyTextLight : Theme.of(context).textTheme.bodyTextBold,
              children: [
                if (widget.isForPudo)
                  const TextSpan(
                    text: " - utente ",
                  ),
                if (widget.isForPudo)
                  TextSpan(
                    text: "AC${widget.packageModel.userId ?? 0}",
                    style: Theme.of(context).textTheme.bodyTextBold,
                  ),
              ],
            ),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        '${event.createTms?.ddmmyyyy}',
                        style: Theme.of(context).textTheme.bodyTextBold,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: Dimension.paddingS),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.packageStatusMessage ?? "??",
                              style: Theme.of(context).textTheme.bodyTextLight,
                            ),
                            event.notes != null ? Text(event.notes!, style: Theme.of(context).textTheme.captionSmall) : const SizedBox()
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }
}
