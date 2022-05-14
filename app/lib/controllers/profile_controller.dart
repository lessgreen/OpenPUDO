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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/commons/utilities/image_picker_helper.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/widgets/table_view_cell.dart';
import 'package:qui_green/widgets/user_profile_recap_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        _info = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (_, currentUser, __) {
        return FocusDetector(
          onVisibilityGained: () {
            currentUser.triggerUserReload();
          },
          child: SAScaffold(
            isLoading: NetworkManager.instance.networkActivity,
            cupertinoBar: CupertinoNavigationBarFix.build(
              context,
              middle: Text(
                'navTitle'.localized(context),
                style: Theme.of(context).textTheme.navBarTitle,
              ),
              trailing: GestureDetector(
                onTap: () {
                  _setEditEnabled(!_editEnabled, currentUser.user!);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: Dimension.padding),
                  child: _buildEditable(
                    Text(
                      'editButton'.localized(context),
                      style: Theme.of(context).textTheme.bodyText2White,
                    ),
                    Text(
                      'endButton'.localized(context),
                      style: Theme.of(context).textTheme.bodyText2White,
                    ),
                  ),
                ),
              ),
            ),
            body: Stack(
              alignment: Alignment.center,
              children: [
                ListView(
                  controller: _scrollController,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CustomNetworkImage(
                          isCircle: true,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                          url: currentUser.user?.profilePicId,
                        ),
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
                        '${'userSince'.localized(context)} ${currentUser.user?.createTms != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(currentUser.user!.createTms!)) : " "}',
                        style: Theme.of(context).textTheme.bodyTextLight,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    UserProfileRecapWidget(
                      totalUsage: currentUser.user?.packageCount ?? 0,
                      kgCO2Saved: currentUser.user?.savedCO2 ?? '0.0Kg',
                    ),
                    TableViewCell(
                      leading: SvgPicture.asset(
                        ImageSrc.positionLeadingCell,
                        color: AppColors.cardColor,
                        width: 36,
                        height: 36,
                      ),
                      title: 'yourShipment'.localized(context),
                      onTap: () => Navigator.of(context).pushNamed(Routes.packagesList),
                    ),
                    TableViewCell(
                      leading: SvgPicture.asset(
                        ImageSrc.globe,
                        color: AppColors.cardColor,
                        width: 20,
                        height: 20,
                      ),
                      title: 'languageTitle'.localized(context),
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.language);
                      },
                    ),
                    TableViewCell(
                      leading: SvgPicture.asset(
                        ImageSrc.logoutIcon,
                        color: AppColors.cardColor,
                        width: 36,
                        height: 36,
                      ),
                      title: 'logoutTitle'.localized(context),
                      onTap: () {
                        Navigator.pop(context);
                        NetworkManager.instance.setAccessToken(null);
                        currentUser.refresh();
                      },
                    ),
                    TableViewCell(
                      dividerPadding: const EdgeInsets.only(left: 5000),
                      title: "deleteAccount".localized(context),
                      textAlign: TextAlign.center,
                      textStyle: Theme.of(context).textTheme.bodyTextBoldRed,
                      showTrailingChevron: false,
                      onTap: () => _showConfirmationDelete(
                          acceptCallback: () {
                            NetworkManager.instance.deleteUser().then((value) {
                              if (value is String) {
                                SAAlertDialog.displayAlertWithButtons(
                                  context,
                                  'deleteAccountSuccessTitle'.localized(context),
                                  'deleteAccountSuccess'.localized(context),
                                  [
                                    MaterialButton(
                                      child: Text(
                                        'viewData'.localized(context),
                                        style: Theme.of(context).textTheme.bodyTextAccent,
                                      ),
                                      onPressed: () {
                                        launch(value).then((value) {
                                          Navigator.pop(context);
                                          NetworkManager.instance.setAccessToken(null);
                                          currentUser.refresh();
                                        });
                                      },
                                    ),
                                    MaterialButton(
                                      child: Text(
                                        'close'.localized(context),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        NetworkManager.instance.setAccessToken(null);
                                        currentUser.refresh();
                                      },
                                    )
                                  ],
                                );
                              }
                            }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError));
                          },
                          denyCallback: null),
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
                              placeholder: 'placeHolderName'.localized(context),
                              onChanged: (newVal) => _changesMade = true,
                            )),
                            const SizedBox(
                              width: Dimension.padding,
                            ),
                            Expanded(
                              child: CupertinoTextField(
                                controller: _lastNameController,
                                placeholder: 'placeHolderSurname'.localized(context),
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
                    duration: const Duration(milliseconds: 100)),
                _info == null
                    ? const SizedBox()
                    : Positioned(
                        child: Text(
                          'v${_info!.version}#${_info!.buildNumber}',
                          style: Theme.of(context).textTheme.captionSmall,
                        ),
                        bottom: 90,
                      ),
              ],
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
          .catchError((onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError));
      if (result is UserProfile) {
        pass = true;
      } else {
        pass = false;
      }
      if (_image != null) {
        await NetworkManager.instance.photoUpload(_image!).catchError(
              (onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError),
            );
      }
      currentUser.triggerUserReload();
      return pass;
    } else {
      return false;
    }
  }

  void _pickImage() async {
    showImageChoice(context, (value) {
      if (value != null) {
        setState(() {
          _image = value;
        });
        _changesMade = true;
      }
    });
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

  void _showConfirmationDelete({Function? acceptCallback, Function? denyCallback}) {
    SAAlertDialog.displayAlertWithButtons(
      context,
      'deleteAccountTitle'.localized(context),
      'deleteAccountDescription'.localized(context),
      [
        MaterialButton(
          child: Text(
            'deleteAccountButton'.localized(context),
            style: Theme.of(context).textTheme.bodyTextAccent,
          ),
          onPressed: () => acceptCallback?.call(),
        ),
        MaterialButton(
          child: Text(
            'deleteAccountCancel'.localized(context),
          ),
          onPressed: () => denyCallback?.call(),
        ),
      ],
    );
  }
}
