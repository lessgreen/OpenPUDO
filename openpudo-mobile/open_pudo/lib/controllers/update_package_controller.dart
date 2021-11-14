//
//  UpdatePackageController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/09/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sabutton.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/models/user_profile.dart';
import 'package:open_pudo/singletons/network.dart';
import 'package:uuid/uuid.dart';

class UpdatePackageController extends StatefulWidget {
  const UpdatePackageController({Key? key}) : super(key: key);

  @override
  _UpdatePackageControllerState createState() => _UpdatePackageControllerState();
}

class _UpdatePackageControllerState extends State<UpdatePackageController> {
  String _uuid = Uuid().v4();
  String? _note;
  UserProfile? _user;
  List<XFile>? _imageFileList;
  final ImagePicker _picker = ImagePicker();

  get onError => null;

  set _imageFile(XFile? value) {
    _imageFileList = value == null ? null : [value];
  }

  void _takePhotoDidPress(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 3000,
        maxHeight: 3000,
        imageQuality: 60,
      );
      setState(() {
        _imageFile = pickedFile;
      });
      if (pickedFile != null) {
        NetworkManager().deliveryPictureUpload(anImage: File(pickedFile.path), externalFileId: _uuid).then((value) {
          print(value);
        }).catchError((onError) {
          SAAlertDialog.displayAlertWithClose(context, 'Error', onError);
        });
      }
    } catch (e) {
      SAAlertDialog.displayAlertWithClose(context, 'Error', e);
    }
  }

  void _setupDelivery() {
    if (_user == null) {
      return;
    }
    NetworkManager().setupDelivery(userId: _user!.userId, notes: _note, packagePicId: _uuid).then((value) {
      print(value);
      Navigator.of(context).pushNamed('/successPackage');
    }).catchError((onError) {
      SAAlertDialog.displayAlertWithClose(context, 'Error', onError);
    });
  }

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
          "navTitle".localized(context, 'updatePackageScreen'),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                child: ListTile(
                  title: Row(
                    children: [
                      (_imageFileList != null)
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                              child: Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            )
                          : SizedBox(),
                      Text('takePhoto'.localized(context, 'updatePackageScreen')),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                  ),
                  onTap: () {
                    _takePhotoDidPress(ImageSource.camera);
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: Row(
                    children: [
                      (_user != null)
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                              child: Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            )
                          : SizedBox(),
                      Text('selectUser'.localized(context, 'updatePackageScreen')),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/packageSelectUser').then((value) {
                      if (value != null && value is UserProfile) {
                        setState(() {
                          _user = value;
                        });
                      }
                      print(value);
                    });
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: Row(
                    children: [
                      (_note != null)
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                              child: Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            )
                          : SizedBox(),
                      Text('addNote'.localized(context, 'updatePackageScreen')),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/packageAddNote').then((value) {
                      if (value != null && value is String) {
                        setState(() {
                          _note = value;
                        });
                      }
                      print(value);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: SAButton(
                    expanded: true,
                    fixedSize: Size.fromHeight(48),
                    backgroundColor: _user != null ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    label: "nextButton".localized(context, "updatePackageScreen"),
                    onPressed: _user != null
                        ? () {
                            _setupDelivery();
                          }
                        : null,
                    borderRadius: 22.0),
              )
            ],
          ),
        ),
      ),
      isLoading: NetworkManager().networkActivity,
    );
  }
}
