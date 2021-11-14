//
//  PackageAddNoteController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/09/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_pudo/commons/sabutton.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/singletons/network.dart';

class PackageAddNoteController extends StatefulWidget {
  const PackageAddNoteController({Key? key}) : super(key: key);

  @override
  _PackageAddNoteControllerState createState() => _PackageAddNoteControllerState();
}

class _PackageAddNoteControllerState extends State<PackageAddNoteController> {
  String? _note;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SAScaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          "addNote".localized(context, 'updatePackageScreen'),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  minLines: 7,
                  maxLines: 7,
                  decoration: InputDecoration(
                    hintText: "addNote".localized(context, 'updatePackageScreen'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                  onChanged: (newValue) {
                    _note = newValue;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                  child: SAButton(
                      expanded: true,
                      fixedSize: Size.fromHeight(48),
                      backgroundColor: Theme.of(context).primaryColor,
                      label: "nextButton".localized(context, "updatePackageScreen"),
                      onPressed: () {
                        Navigator.of(context).pop(_note);
                      },
                      borderRadius: 22.0),
                )
              ],
            ),
          ),
        ),
      ),
      isLoading: NetworkManager().networkActivity,
    );
  }
}
