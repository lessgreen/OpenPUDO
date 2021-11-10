//
//  EditUserProfileController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/07/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sabutton.dart';
import 'package:open_pudo/commons/sanetwork_image.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/models/user_profile.dart';
import 'package:open_pudo/singletons/current_user.dart';
import 'package:open_pudo/singletons/network.dart';
import 'package:provider/provider.dart';

class EditUserProfileController extends StatefulWidget {
  const EditUserProfileController({Key? key}) : super(key: key);

  @override
  _EditUserProfileControllerState createState() => _EditUserProfileControllerState();
}

class _EditUserProfileControllerState extends State<EditUserProfileController> {
  final _formKey = GlobalKey<FormState>();
  late String _firstName;
  FocusNode _firstNameNode = FocusNode();
  late String _lastName;
  FocusNode _lastNameNode = FocusNode();
  late String? _ssn;
  FocusNode _ssnNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  _saveDidPress(UserProfile editedProfile) {
    NetworkManager().setMyProfile(editedProfile).then((response) {
      if (response is UserProfile) {
        Provider.of<CurrentUser>(context, listen: false).user = response;
        Navigator.of(context).pop();
      }
    }).catchError((onError) {
      SAAlertDialog.displayAlertWithClose(
        context,
        "genericTitle".localized(context, 'alert'),
        onError,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);

    if (_currentUser.user != null) {
      _firstName = _currentUser.user!.firstName;
      _lastName = _currentUser.user!.lastName;
      _ssn = _currentUser.user!.ssn;
    }
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
        title: Text('navTitle'.localized(context, 'editUserProfileScreen')),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: GestureDetector(
                    onTap: () {
                      _getImage();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: SANetworkImage(
                        url: _currentUser.user?.profilePicId,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                        child: TextFormField(
                          initialValue: _firstName,
                          focusNode: _firstNameNode,
                          decoration: InputDecoration(hintText: 'firstNamePlaceHolder'.localized(context, "editUserProfileScreen")),
                          validator: (value) {
                            if (value == null || value.length == 0) return 'invalidFirstName'.localized(context, "editUserProfileScreen");
                            return null;
                          },
                          onChanged: (value) {
                            _firstName = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                        child: TextFormField(
                          initialValue: _lastName,
                          focusNode: _lastNameNode,
                          decoration: InputDecoration(hintText: 'lastNamePlaceHolder'.localized(context, "editUserProfileScreen")),
                          validator: (value) {
                            if (value == null || value.length == 0) return 'invalidLastName'.localized(context, "editUserProfileScreen");
                            return null;
                          },
                          onChanged: (value) {
                            _lastName = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                        child: TextFormField(
                          initialValue: _ssn,
                          focusNode: _ssnNode,
                          decoration: InputDecoration(hintText: 'ssnPlaceHolder'.localized(context, "editUserProfileScreen")),
                          onChanged: (value) {
                            _ssn = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                  child: SAButton(
                    expanded: true,
                    fixedSize: Size.fromHeight(48),
                    label: "submit".localized(context, "editUserProfileScreen"),
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _currentUser.user != null) {
                        _currentUser.user!.firstName = _firstName;
                        _currentUser.user!.lastName = _lastName;
                        _currentUser.user!.ssn = _ssn;
                        _saveDidPress(_currentUser.user!);
                      }
                    },
                    borderRadius: 22.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<CupertinoActionSheetAction> _buildActions(BuildContext context, BuildContext sheetContext) {
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
    List<CupertinoActionSheetAction> actions = [];

    actions = [
      CupertinoActionSheetAction(
        child: Text('camera'.localized(context, 'editUserProfileScreen')),
        onPressed: () async {
          try {
            final pickedFile = await _picker.pickImage(
              source: ImageSource.camera,
              maxWidth: 3000,
              maxHeight: 3000,
              imageQuality: 60,
            );
            if (pickedFile != null) {
              _updateImage(File(pickedFile.path));
            }
          } catch (e) {
            SAAlertDialog.displayAlertWithClose(context, 'Error', e);
          }
          Navigator.of(sheetContext).pop();
        },
      ),
      CupertinoActionSheetAction(
        child: Text('gallery'.localized(context, 'editUserProfileScreen')),
        onPressed: () async {
          try {
            final pickedFile = await _picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 3000,
              maxHeight: 3000,
              imageQuality: 60,
            );
            if (pickedFile != null) {
              _updateImage(File(pickedFile.path));
            }
          } catch (e) {
            SAAlertDialog.displayAlertWithClose(context, 'Error', e);
          }
          Navigator.of(sheetContext).pop();
        },
      ),
    ];
    if (_currentUser.user?.profilePicId != null) {
      actions.add(
        CupertinoActionSheetAction(
          child: Text('delete'.localized(context, 'editUserProfileScreen')),
          onPressed: () async {
            _deleteImage();
            Navigator.of(sheetContext).pop();
          },
        ),
      );
    }
    return actions;
  }

  Future _getImage() async {
    showCupertinoModalPopup(
        context: context,
        builder: (sheetContext) {
          return CupertinoActionSheet(
            title: Text('chooseAnOption'.localized(context, 'editUserProfileScreen')),
            actions: _buildActions(context, sheetContext),
            cancelButton: CupertinoActionSheetAction(
              child: Text('cancel'.localized(context, 'editUserProfileScreen')),
              onPressed: () {
                Navigator.of(sheetContext).pop();
              },
            ),
          );
        });
  }

  void _updateImage(File anImage) {
    NetworkManager().photoupload(anImage).then(
      (response) {
        if (response is UserProfile) {
          Provider.of<CurrentUser>(context, listen: false).user = response;
        } else {
          throw (response);
        }
      },
    ).catchError(
      (onError) {
        SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, 'alert'), onError);
      },
    );
  }

  void _deleteImage() {
    NetworkManager().deleteProfilePic().then(
      (response) {
        if (response is UserProfile) {
          Provider.of<CurrentUser>(context, listen: false).user = response;
        } else {
          throw (response);
        }
      },
    ).catchError(
      (onError) {
        SAAlertDialog.displayAlertWithClose(context, "genericTitle".localized(context, 'alert'), onError);
      },
    );
  }
}
