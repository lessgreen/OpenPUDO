//
//  EditBusinessProfileController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/07/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_pudo/commons/Localization.dart';
import 'package:open_pudo/commons/alert_dialog.dart';
import 'package:open_pudo/commons/sabutton.dart';
import 'package:open_pudo/commons/sanetwork_image.dart';
import 'package:open_pudo/commons/sascaffold.dart';
import 'package:open_pudo/models/address_marker.dart';
import 'package:open_pudo/models/pudo_profile.dart';
import 'package:open_pudo/singletons/current_user.dart';
import 'package:open_pudo/singletons/network.dart';
import 'package:provider/provider.dart';

class EditBusinessProfileController extends StatefulWidget {
  const EditBusinessProfileController({Key? key}) : super(key: key);

  @override
  _EditBusinessProfileControllerState createState() => _EditBusinessProfileControllerState();
}

class _EditBusinessProfileControllerState extends State<EditBusinessProfileController> {
  final _formKey = GlobalKey<FormState>();
  late String _businessName;
  FocusNode _businessNameNode = FocusNode();
  late String _phone;
  FocusNode _phoneNode = FocusNode();
  late String? _vat;
  FocusNode _vatNode = FocusNode();
  late String? _contactNotes;
  FocusNode _contactNotesNode = FocusNode();
  FocusNode _addressNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  _saveDidPress(PudoProfile? editedProfile) {
    if (editedProfile == null) {
      return;
    }
    NetworkManager().setMyPudoProfile(editedProfile).then((response) {
      if (response is PudoProfile) {
        Provider.of<CurrentUser>(context, listen: false).pudoProfile = response;
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

    if (_currentUser.pudoProfile != null) {
      _businessName = _currentUser.pudoProfile?.businessName ?? "";
      _contactNotes = _currentUser.pudoProfile?.contactNotes ?? "";
      _phone = _currentUser.pudoProfile?.phoneNumber ?? "";
      _vat = _currentUser.pudoProfile?.vat ?? "";
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
        title: Text('navTitle'.localized(context, 'editBusinessProfileScreen')),
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
                        url: _currentUser.pudoProfile?.profilePicId,
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
                          initialValue: _businessName,
                          focusNode: _businessNameNode,
                          decoration: InputDecoration(hintText: 'businessNamePlaceHolder'.localized(context, "editBusinessProfileScreen")),
                          validator: (value) {
                            if (value == null || value.length == 0) return 'invalidBusinessName'.localized(context, "editBusinessProfileScreen");
                            return null;
                          },
                          onChanged: (value) {
                            _businessName = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                        child: TypeAheadFormField(
                          itemBuilder: (context, address) {
                            if (address is AddressMarker) {
                              return ListTile(
                                title: Text(address.label),
                              );
                            }
                            return SizedBox();
                          },
                          suggestionsCallback: (newValue) {
                            return NetworkManager().getAddresses(text: newValue).then(
                              (responseList) {
                                if (responseList is List) {
                                  return responseList;
                                } else {
                                  return [];
                                }
                              },
                            );
                          },
                          onSuggestionSelected: (itemSelected) {
                            if (itemSelected is AddressMarker) {
                              NetworkManager().setMyPudoAddress(itemSelected).then(
                                (response) {
                                  if (response is PudoProfile) {
                                    _currentUser.pudoProfile = response;
                                  }
                                },
                              ).catchError((onError) {
                                SAAlertDialog.displayAlertWithClose(context, 'genericTitle'.localized(context, 'alert'), onError.toString());
                              });
                              print(itemSelected.label);
                            }
                          },
                          initialValue: _currentUser.pudoProfile?.address?.label ?? null,
                          textFieldConfiguration: TextFieldConfiguration(
                            focusNode: _addressNode,
                            decoration: InputDecoration(
                              hintText: 'addressPlaceHolder'.localized(context, "editBusinessProfileScreen"),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length == 0) return 'invalidAddress'.localized(context, "editBusinessProfileScreen");
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                        child: TextFormField(
                          initialValue: _contactNotes,
                          focusNode: _contactNotesNode,
                          decoration: InputDecoration(hintText: 'contactNotesPlaceHolder'.localized(context, "editBusinessProfileScreen")),
                          validator: (value) {
                            if (value == null || value.length == 0) return 'invalidContactNotes'.localized(context, "editBusinessProfileScreen");
                            return null;
                          },
                          onChanged: (value) {
                            _contactNotes = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                        child: TextFormField(
                          initialValue: _vat,
                          focusNode: _vatNode,
                          decoration: InputDecoration(hintText: 'vatPlaceHolder'.localized(context, "editBusinessProfileScreen")),
                          validator: (value) {
                            if (value == null || value.length == 0) return 'invalidVat'.localized(context, "editBusinessProfileScreen");
                            return null;
                          },
                          onChanged: (value) {
                            _vat = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                        child: TextFormField(
                          initialValue: _phone,
                          focusNode: _phoneNode,
                          decoration: InputDecoration(hintText: 'phonePlaceHolder'.localized(context, "editBusinessProfileScreen")),
                          validator: (value) {
                            if (value == null || value.length == 0) return 'invalidPhone'.localized(context, "editBusinessProfileScreen");
                            return null;
                          },
                          onChanged: (value) {
                            _phone = value;
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
                    label: "submit".localized(context, "editBusinessProfileScreen"),
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _currentUser.pudoProfile != null) {
                        _currentUser.pudoProfile?.businessName = _businessName;
                        _currentUser.pudoProfile?.contactNotes = _contactNotes;
                        _currentUser.pudoProfile?.vat = _vat;
                        _currentUser.pudoProfile?.phoneNumber = _phone;
                        _saveDidPress(_currentUser.pudoProfile);
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
        child: Text('camera'.localized(context, 'editBusinessProfileScreen')),
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
        child: Text('gallery'.localized(context, 'editBusinessProfileScreen')),
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
            SAAlertDialog.displayAlertWithClose(context, 'Error', e.toString());
          }
          Navigator.of(sheetContext).pop();
        },
      ),
    ];
    if (_currentUser.pudoProfile?.profilePicId != null) {
      actions.add(
        CupertinoActionSheetAction(
          child: Text('delete'.localized(context, 'editBusinessProfileScreen')),
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
            title: Text('chooseAnOption'.localized(context, 'editBusinessProfileScreen')),
            actions: _buildActions(context, sheetContext),
            cancelButton: CupertinoActionSheetAction(
              child: Text('cancel'.localized(context, 'editBusinessProfileScreen')),
              onPressed: () {
                Navigator.of(sheetContext).pop();
              },
            ),
          );
        });
  }

  void _deleteImage() {
    NetworkManager().deleteProfilePic(isPudo: true).then(
      (response) {
        if (response is PudoProfile) {
          Provider.of<CurrentUser>(context, listen: false).pudoProfile = response;
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

  void _updateImage(File anImage) {
    NetworkManager().photoupload(anImage, isPudo: true).then(
      (response) {
        if (response is PudoProfile) {
          Provider.of<CurrentUser>(context, listen: false).pudoProfile = response;
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
