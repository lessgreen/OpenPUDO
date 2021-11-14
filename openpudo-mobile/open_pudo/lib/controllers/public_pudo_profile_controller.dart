//
//  PublicPudoProfileController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 05/07/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sabutton.dart';
import 'package:open_pudo/commons/sanetwork_image.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/models/pudo_profile.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/singletons/current_user.dart';
import 'package:open_pudo/singletons/network.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicPudoProfileController extends StatefulWidget {
  final dynamic arguments;

  PublicPudoProfileController({Key? key, this.arguments}) : super(key: key);

  @override
  _PublicPudoProfileControllerState createState() => _PublicPudoProfileControllerState();
}

class _PublicPudoProfileControllerState extends State<PublicPudoProfileController> {
  PudoProfile? dataSource;
  bool _alreadyFavorite = false;

  @override
  void initState() {
    super.initState();
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);

    if (widget.arguments != null && widget.arguments is Map<String, dynamic>) {
      Map<String, dynamic> infoDict = widget.arguments;
      if (infoDict.containsKey("dataSource")) {
        dataSource = infoDict["dataSource"];

        if (_currentUser.user != null) {
          _checkIfPudoIsAlreadyFavorite();
        }
      }
    }
  }

  _addToFavorites() {
    NetworkManager().addPudoFavorite(dataSource!.pudoId!.toString()).then((response) {
      setState(() {
        _alreadyFavorite = true;
      });
      print(response);
    }).catchError(
      (onError) => SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, 'alert'), onError),
    );
  }

  _removeFromFavorites() {
    NetworkManager().removePudoFavorite(dataSource!.pudoId!.toString()).then((response) {
      setState(() {
        _alreadyFavorite = false;
      });
      print(response);
    }).catchError(
      (onError) => SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, 'alert'), onError),
    );
  }

  _checkIfPudoIsAlreadyFavorite() {
    if (dataSource?.pudoId == null) {
      return;
    }
    NetworkManager().getMyPudos().then((response) {
      if (response is List<PudoProfile>) {
        setState(() {
          _alreadyFavorite = response.containsPudo(pudoId: dataSource!.pudoId!);
        });
      }
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SAScaffold(
      isLoading: NetworkManager().networkActivity,
      appBar: AppBar(
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          "navTitle".localized(context, 'pudoPublicProfileScreen'),
        ),
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
                    url: dataSource?.profilePicId,
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
                      "${dataSource?.businessName ?? "n/a"}",
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
                      "${dataSource?.address?.label ?? "addressNotAvailable".localized(context, 'pudoPublicProfileScreen')}",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    dataSource?.vat != null
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Text(
                              "P.IVA ${dataSource!.vat}",
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
              dataSource?.phoneNumber != null
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
                                    if (await canLaunch('tel://${dataSource!.phoneNumber!}')) {
                                      launch('tel://${dataSource!.phoneNumber!}');
                                    }
                                  },
                                  child: Text(dataSource!.phoneNumber!, style: Theme.of(context).textTheme.subtitle1),
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
              dataSource?.contactNotes != null
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Column(
                            children: [
                              Text(
                                "${dataSource?.contactNotes ?? "n/a"}",
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
              SAButton(
                label: (_alreadyFavorite ? 'removePudo' : 'addPudo').localized(context, 'pudoPublicProfileScreen'),
                fixedSize: Size(double.infinity, 46),
                borderRadius: 23,
                onPressed: () {
                  _alreadyFavorite ? _removeFromFavorites() : _addToFavorites();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
