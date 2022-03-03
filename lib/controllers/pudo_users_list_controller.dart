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
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/commons/utilities/network_error_helper.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/models/user_summary.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/widgets/table_view_cell.dart';

class PudoUsersListController extends StatefulWidget {
  const PudoUsersListController({Key? key, this.isOnReceivePack = false}) : super(key: key);
  final bool isOnReceivePack;

  @override
  _PudoUsersListControllerState createState() => _PudoUsersListControllerState();
}

class _PudoUsersListControllerState extends State<PudoUsersListController> {
  List<UserSummary>? usersList;

  List<UserSummary> get filteredUsersList => usersList != null ? usersList!.where((element) => handleUserSearch(searchedValue, element)).toList() : [];

  bool handleUserSearch(String search, UserSummary user) {
    if (search.isEmpty) {
      return true;
    }
    List<String> splittedSearch = search.toLowerCase().split(" ");
    List<String> splittedUser = "${user.firstName} ${user.lastName} AC${user.userId.toString()}".toLowerCase().split(" ");
    for (String splitSearch in splittedSearch) {
      for (String splitValue in splittedUser) {
        if (splitValue.contains(splitSearch)) {
          return true;
        }
      }
    }
    return false;
  }

  String searchedValue = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (context, currentUser, _) => FutureBuilder<void>(
        future: _getUsers(),
        builder: (context, snapshot) => Material(
          child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBarFix.build(
              context,
              middle: Text(
                widget.isOnReceivePack ? 'Scegli un destinatario' : "I tuoi utenti",
                style: Theme.of(context).textTheme.navBarTitle,
              ),
              leading: CupertinoNavigationBarBackButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            child: SAScaffold(
              isLoading: NetworkManager.instance.networkActivity,
              body: Column(
                children: [
                  CupertinoTextField(
                    placeholder: 'Cerca per nome',
                    padding: const EdgeInsets.all(Dimension.padding),
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: Dimension.padding),
                      child: Icon(
                        CupertinoIcons.search,
                        color: searchedValue.isEmpty ? AppColors.colorGrey : AppColors.primaryColorDark,
                      ),
                    ),
                    placeholderStyle: const TextStyle(color: AppColors.colorGrey),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimension.borderRadiusSearch)),
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    onChanged: (newValue) {
                      setState(() {
                        searchedValue = newValue;
                      });
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        usersList = null;
                        currentUser.triggerReload();
                      },
                      child: usersList == null
                          ? const SizedBox()
                          : usersList!.isEmpty
                              ? const SizedBox()
                              : _buildUsers(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //MARK: Build widget accessories

  Widget _buildUsers() {
    return ListView.builder(
      itemBuilder: (context, index) => TableViewCell(
        onTap: () {
          if (widget.isOnReceivePack) {
            Navigator.pop(context, filteredUsersList[index]);
          } else {
            _onUserTap(filteredUsersList[index]);
            //Navigator.pushNamed("unkwon");
          }
        },
        fullWidth: true,
        showTrailingChevron: true,
        leading: CustomNetworkImage(
          isCircle: true,
          url: filteredUsersList[index].profilePicId,
          width: 50,
          height: 50,
        ),
        leadingWidth: 50,
        title: "${filteredUsersList[index].firstName} ${filteredUsersList[index].lastName} AC${filteredUsersList[index].userId.toString()}",
      ),
      itemCount: filteredUsersList.length,
    );
  }

  _onUserTap(UserSummary user) {
    NetworkManager.instance.getUserProfile(userId: user.userId!).then(
      (response) {
        if (response is UserProfile) {
          Navigator.of(context).pushNamed(Routes.userDetail, arguments: response);
        } else {
          SAAlertDialog.displayAlertWithClose(context, "Error", "Ops!, Qualcosa e' andato storto");
        }
      },
    ).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  //MARK: Actions

  Future<void> _getUsers() {
    //Check if firstFetch was ever done, we need to do this because of the search feature
    if (usersList == null) {
      return NetworkManager.instance.getMyPudoUsers().then((value) {
        if (value is List<UserSummary>) {
          usersList = value;
        } else {
          NetworkErrorHelper.helper(context, value);
        }
      }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
    }
    return Future.value();
  }
}
