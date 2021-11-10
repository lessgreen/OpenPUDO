//
//  BusinessPudoProfileController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 10/07/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:open_pudo/commons/sanetwork_image.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/singletons/current_user.dart';
import 'package:open_pudo/singletons/network.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessPudoProfileController extends StatefulWidget {
  final dynamic arguments;

  BusinessPudoProfileController({Key? key, this.arguments}) : super(key: key);

  @override
  _BusinessPudoProfileControllerState createState() => _BusinessPudoProfileControllerState();
}

class _BusinessPudoProfileControllerState extends State<BusinessPudoProfileController> {
  @override
  void initState() {
    super.initState();
    // if (widget.arguments != null && widget.arguments is Map<String, dynamic>) {
    //   Map<String, dynamic> infoDict = widget.arguments;
    //   if (infoDict.containsKey("dataSource")) {
    //     dataSource = infoDict["dataSource"];
    //   }
    // }
  }

  _editBusinessProfileDidPress() {
    Navigator.of(context).pushNamed('/editBusinessProfile');
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: true);

    return SAScaffold(
      isLoading: NetworkManager().networkActivity,
      appBar: AppBar(
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          "navTitle".localized(context, 'businessPudoProfileScreen'),
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: IconButton(
                onPressed: () {
                  _editBusinessProfileDidPress();
                },
                icon: Icon(Icons.edit),
              )),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: SANetworkImage(
                    url: _currentUser.pudoProfile?.profilePicId,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: Column(
                  children: [
                    Text(
                      "${_currentUser.pudoProfile?.businessName ?? "n/a"}",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Column(
                  children: [
                    Text(
                      "${_currentUser.pudoProfile?.address?.label ?? "addressNotAvailable".localized(context, 'pudoPublicProfileScreen')}",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    _currentUser.pudoProfile?.vat != null
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Text(
                              "P.IVA ${_currentUser.pudoProfile!.vat}",
                              style: Theme.of(context).textTheme.caption,
                            ),
                          )
                        : SizedBox()
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Divider(),
              ),
              _currentUser.pudoProfile?.phoneNumber != null
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone,
                                size: 32,
                                color: Theme.of(context).primaryColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (await canLaunch('tel://${_currentUser.pudoProfile!.phoneNumber!}')) {
                                      launch('tel://${_currentUser.pudoProfile!.phoneNumber!}');
                                    }
                                  },
                                  child: Text(_currentUser.pudoProfile!.phoneNumber!, style: Theme.of(context).textTheme.subtitle1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Divider(),
                        ),
                      ],
                    )
                  : SizedBox(),
              _currentUser.pudoProfile?.contactNotes != null
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Column(
                            children: [
                              Text(
                                "${_currentUser.pudoProfile?.contactNotes ?? "n/a"}",
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Divider(),
                        ),
                      ],
                    )
                  : SizedBox(),
              Padding(padding: const EdgeInsets.fromLTRB(0, 32, 0, 0), child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
