//
//  SuccessPackageController.dart
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

class SuccessPackageController extends StatefulWidget {
  const SuccessPackageController({Key? key}) : super(key: key);

  @override
  _SuccessPackageControllerState createState() => _SuccessPackageControllerState();
}

class _SuccessPackageControllerState extends State<SuccessPackageController> {
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
        leading: SizedBox(),
        title: Text(
          "doneTitle".localized(context, 'updatePackageScreen'),
        ),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 160),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 32, 0, 32),
                child: Text(
                  "doneTitle".localized(context, 'updatePackageScreen'),
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Text(
                  "doneDescription".localized(context, 'updatePackageScreen'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: SAButton(
                    expanded: true,
                    fixedSize: Size.fromHeight(48),
                    backgroundColor: Theme.of(context).primaryColor,
                    label: "closeButton".localized(context, "updatePackageScreen"),
                    borderRadius: 22.0,
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }),
              )
            ],
          ),
        ),
      ),
      isLoading: NetworkManager().networkActivity,
    );
  }
}
