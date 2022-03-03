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

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/utilities/network_error_helper.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/models/user_summary.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/profile_pic_box.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/widgets/table_view_cell.dart';

class PackageReceivedController extends StatefulWidget {
  const PackageReceivedController({Key? key}) : super(key: key);

  @override
  _PackageReceivedControllerState createState() => _PackageReceivedControllerState();
}

class _PackageReceivedControllerState extends State<PackageReceivedController> {
  UserSummary? selectedUser;
  File? image;
  final TextEditingController notesController = TextEditingController();

  void pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.media);
    if (result != null) {
      File file = File(result.files.first.path ?? "");
      setState(() {
        image = file;
      });
    }
  }

  void sendRequest() {
    NetworkManager.instance.setupDelivery(userId: selectedUser!.userId ?? 0, notes: notesController.text.trim()).then((value) {
      if (value != null && value is PudoPackage) {
        if (image != null) {
          NetworkManager.instance.packagePhotoUpload(image!, value.packageId).catchError((onError) => print(onError));
        }
        Navigator.of(context).pushReplacementNamed(Routes.notifySent, arguments: "${selectedUser!.firstName} ${selectedUser!.lastName}");
      } else {
        NetworkErrorHelper.helper(context, value);
      }
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

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
              'Ho ricevuto un pacco',
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
                  height: Dimension.paddingM,
                ),
                ProfilePicBox(
                  onTap: pickImage,
                  image: image,
                  title: "Scatta una foto\nal pacco",
                  mainIconSvgAsset: ImageSrc.shipmentLeadingCell,
                ),
                const SizedBox(
                  height: Dimension.paddingM,
                ),
                TableViewCell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.searchRecipient).then((value) {
                      if (value != null && value is UserSummary) {
                        setState(() {
                          selectedUser = value;
                        });
                      }
                    });
                  },
                  fullWidth: true,
                  showTopDivider: true,
                  showTrailingChevron: true,
                  title: selectedUser == null ? "Scegli un destinatario" : "${selectedUser!.firstName} ${selectedUser!.lastName} AC${selectedUser!.userId.toString()}",
                  leading: const Icon(
                    CupertinoIcons.person,
                    color: AppColors.primaryColorDark,
                    size: 26,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: Dimension.padding + Dimension.paddingXS, top: Dimension.padding),
                      child: Icon(
                        CupertinoIcons.info_circle_fill,
                        color: AppColors.primaryColorDark,
                      ),
                    ),
                    Expanded(
                      child: CupertinoTextField(
                        placeholder: "Aggiungi una descrizione opzionale utile per la notifica di consegna al tuo utente",
                        padding: const EdgeInsets.all(Dimension.padding),
                        prefixMode: OverlayVisibilityMode.always,
                        placeholderStyle: const TextStyle(color: AppColors.colorGrey),
                        controller: notesController,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimension.borderRadiusSearch)),
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        minLines: 2,
                        maxLines: 8,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  height: 1,
                ),
                const SizedBox(
                  height: Dimension.paddingL,
                ),
                MainButton(enabled: selectedUser != null, text: "Avanti", onPressed: sendRequest)
              ],
            ),
          )),
    );
  }
}
