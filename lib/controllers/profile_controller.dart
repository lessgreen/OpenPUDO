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
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/widgets/table_view_cell.dart';
import 'package:qui_green/widgets/user_profile_recap_widget.dart';

class ProfileController extends StatefulWidget {
  const ProfileController({Key? key}) : super(key: key);

  @override
  _ProfileControllerState createState() => _ProfileControllerState();
}

class _ProfileControllerState extends State<ProfileController> with ConnectionAware {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? _image;
  bool _editEnabled = false;
  bool _changesMade = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (_, currentUser, __) {
        return Material(
          child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBarFix.build(
              context,
              middle: Text(
                'Il tuo profilo',
                style: Theme.of(context).textTheme.navBarTitle,
              ),
              trailing: InkWell(
                onTap: () {
                  _setEditEnabled(!_editEnabled, currentUser.user!);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: Dimension.padding),
                  child: _buildEditable(
                    const Icon(
                      CupertinoIcons.pencil_circle,
                      color: Colors.white,
                      size: 26,
                    ),
                    Text(
                      "Fine",
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              ),
            ),
            child: SAScaffold(
              isLoading: NetworkManager.instance.networkActivity,
              body: Stack(
                children: [
                  ListView(
                    controller: _scrollController,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CustomNetworkImage(height: 150, width: 150, fit: BoxFit.cover, url: currentUser.user?.profilePicId),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildEditable(
                        Center(
                          child: Text(
                            "${currentUser.user?.firstName ?? " "} ${currentUser.user?.lastName ?? " "}",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Utente dal ${currentUser.user?.createTms != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(currentUser.user!.createTms!)) : " "}',
                          style: Theme.of(context).textTheme.bodyTextLight,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const UserProfileRecapWidget(
                        totalUsage: 123,
                        kgCO2Saved: 456,
                      ),
                      TableViewCell(
                        leading: SvgPicture.asset(
                          ImageSrc.positionLeadingCell,
                          color: AppColors.cardColor,
                          width: 36,
                          height: 36,
                        ),
                        title: "Le tue spedizioni",
                        onTap: () => Navigator.of(context).pushNamed(Routes.packagesList),
                      ),
                      TableViewCell(
                        leading: SvgPicture.asset(
                          ImageSrc.logoutIcon,
                          color: AppColors.cardColor,
                          width: 36,
                          height: 36,
                        ),
                        title: "Logout",
                        onTap: () {
                          Navigator.pop(context);
                          NetworkManager.instance.setAccessToken(null);
                          currentUser.refresh();
                        },
                      ),
                      TableViewCell(
                        title: "Elimina account",
                        textAlign: TextAlign.center,
                        textStyle: Theme.of(context).textTheme.bodyTextBold?.copyWith(
                              color: Colors.red,
                            ),
                        showTrailingChevron: false,
                      )
                    ],
                  ),
                  IgnorePointer(
                    ignoring: !_editEnabled,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      color: _editEnabled ? Colors.black.withOpacity(0.4) : Colors.transparent,
                    ),
                  ),
                  AnimatedCrossFade(
                      firstChild: SizedBox(
                        width: MediaQuery.of(context).size.width,
                      ),
                      secondChild: Column(
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: _image != null
                                        ? Image.file(
                                            _image!,
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.cover,
                                          )
                                        : CustomNetworkImage(height: 150, width: 150, fit: BoxFit.cover, url: currentUser.user?.profilePicId),
                                  ),
                                  Container(
                                    width: 150,
                                    padding: const EdgeInsets.all(Dimension.paddingS),
                                    alignment: Alignment.topRight,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: Container(
                                        color: Colors.white,
                                        width: 32,
                                        height: 32,
                                        child: const Icon(
                                          CupertinoIcons.pencil_circle,
                                          color: AppColors.primaryColorDark,
                                          size: 31,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: Dimension.padding,
                              ),
                              Expanded(
                                  child: CupertinoTextField(
                                controller: _firstNameController,
                                placeholder: "Nome",
                                onChanged: (newVal) => _changesMade = true,
                              )),
                              const SizedBox(
                                width: Dimension.padding,
                              ),
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _lastNameController,
                                  placeholder: "Cognome",
                                  onChanged: (newVal) => _changesMade = true,
                                ),
                              ),
                              const SizedBox(
                                width: Dimension.padding,
                              ),
                            ],
                          ),
                        ],
                      ),
                      crossFadeState: _editEnabled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 100))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditable(Widget view, Widget edit) => AnimatedCrossFade(
        firstChild: view,
        secondChild: edit,
        crossFadeState: _editEnabled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 150),
      );

  Future<bool> _saveChanges() async {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    if (_firstNameController.text.trim().isNotEmpty && _lastNameController.text.trim().isNotEmpty) {
      bool pass = false;
      var result = await NetworkManager.instance
          .updateUser(firstName: _firstNameController.text, lastName: _lastNameController.text)
          .catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
      if (result is UserProfile) {
        pass = true;
      } else {
        pass = false;
      }
      if (_image != null) {
        await NetworkManager.instance.photoUpload(_image!).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
      }
      currentUser.triggerUserReload();
      return pass;
    } else {
      return false;
    }
  }

  void _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
    if (result != null) {
      File file = File(result.files.first.path ?? "");
      setState(() {
        _image = file;
      });
      _changesMade = true;
    }
  }

  void _setEditEnabled(bool newVal, UserProfile profile) async {
    if (newVal) {
      ///Jump main listView onTop
      _changesMade = false;
      _scrollController.jumpTo(0);
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
    } else {
      if (_changesMade) {
        bool result = await _saveChanges();
        if (result) {
          _changesMade = false;
          _image = null;
          _firstNameController.clear();
          _lastNameController.clear();
        }
      }
    }
    setState(() {
      _editEnabled = newVal;
    });
  }
}
