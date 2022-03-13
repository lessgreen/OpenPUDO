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
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/widgets/table_view_cell.dart';
import 'package:qui_green/widgets/user_profile_recap_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PudoProfileController extends StatefulWidget {
  const PudoProfileController({Key? key}) : super(key: key);

  @override
  _PudoProfileControllerState createState() => _PudoProfileControllerState();
}

class _PudoProfileControllerState extends State<PudoProfileController> with ConnectionAware {
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
          child: Material(
            child: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBarFix.build(context,
                  middle: Text(
                    'navTitle'.localized(context),
                    style: Theme.of(context).textTheme.navBarTitle,
                  ),
                  trailing: InkWell(
                    onTap: () => Navigator.pushNamed(context, Routes.profileEdit),
                    child: const Padding(
                      padding: EdgeInsets.only(right: Dimension.padding),
                      child: Icon(
                        CupertinoIcons.pencil_circle,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  )),
              child: SAScaffold(
                isLoading: NetworkManager.instance.networkActivity,
                body: Stack(
                  alignment: Alignment.center,
                  children: [
                    ListView(
                      children: [
                        AspectRatio(
                          aspectRatio: 18 / 9,
                          child: CustomNetworkImage(
                            url: currentUser.pudoProfile?.pudoPicId,
                          ),
                        ),
                        const SizedBox(
                          height: Dimension.paddingM,
                        ),
                        Center(
                          child: Text(
                            currentUser.pudoProfile?.businessName ?? " ",
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            '${'userSince'.localized(context)} ${currentUser.pudoProfile?.createTms != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(currentUser.pudoProfile!.createTms!)) : " "}',
                            style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: AppColors.primaryTextColor),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        UserProfileRecapWidget(
                          totalUsage: currentUser.pudoProfile?.packageCount ?? 0,
                          kgCO2Saved: currentUser.pudoProfile?.savedCO2 ?? '0.0Kg',
                          isForPudo: true,
                        ),
                        TableViewCell(
                            showTopDivider: true,
                            fullWidth: true,
                            leading: const Icon(
                              CupertinoIcons.person_fill,
                              color: AppColors.primaryColorDark,
                              size: 26,
                            ),
                            title: 'yourUsers'.localized(context),
                            onTap: () {
                              Navigator.of(context).pushNamed(Routes.pudoUsersList);
                            }),
                        TableViewCell(
                          leading: SvgPicture.asset(
                            ImageSrc.logoutIcon,
                            color: AppColors.cardColor,
                            width: 36,
                            height: 36,
                          ),
                          title: 'logoutButton'.localized(context),
                          onTap: () {
                            Navigator.pop(context);
                            NetworkManager.instance.setAccessToken(null);
                            currentUser.refresh();
                          },
                        ),
                        TableViewCell(
                          title: "deleteAccount".localized(context),
                          textAlign: TextAlign.center,
                          textStyle: Theme.of(context).textTheme.bodyTextBold?.copyWith(color: Colors.red),
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
                                            style: const TextStyle(color: AppColors.primaryColorDark),
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
            ),
          ),
        );
      },
    );
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
            style: const TextStyle(color: AppColors.primaryColorDark),
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
