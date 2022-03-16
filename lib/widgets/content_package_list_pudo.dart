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

import 'package:flutter/material.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/error_screen_widget.dart';
import 'package:qui_green/widgets/listview_header.dart';
import 'package:qui_green/widgets/package_tile.dart';

class ContentPackagesListPudo extends StatefulWidget {
  const ContentPackagesListPudo({
    Key? key,
    required this.searchValue,
    required this.isOnReceivePack,
  }) : super(key: key);
  final String searchValue;
  final bool isOnReceivePack;

  @override
  State<ContentPackagesListPudo> createState() => _ContentPackagesListPudoState();
}

class _ContentPackagesListPudoState extends State<ContentPackagesListPudo> {
  List<PackageSummary> _availablePackages = [];
  String? _errorDescription;
  List<PackageSummary> get _filteredPackagesList => _availablePackages.where((element) => _handlePackageSearch(widget.searchValue, element)).toList();

  @override
  void initState() {
    super.initState();
    _fetchPackages().then(
      (response) {
        if (response is List<PackageSummary>) {
          setState(() {
            _availablePackages = response;
          });
        }
      },
    );
  }

  _refreshDidTriggered() {
    setState(() {
      _availablePackages.clear();
    });
    _fetchPackages().then(
      (response) {
        if (response is List<PackageSummary>) {
          setState(() {
            _availablePackages = response;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _refreshDidTriggered(),
      child: _errorDescription != null
          ? ErrorScreenWidget(
              description: _errorDescription,
            )
          : ListViewHeader(
              hasScrollbar: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _filteredPackagesList.length,
              contentBuilder: (BuildContext context, int index) {
                return PackageTile(
                    onTap: (PackageSummary package) {
                      _onPackageCard(_filteredPackagesList[index]);
                    },
                    packageSummary: _filteredPackagesList[index]);
              },
            ),
    );
  }

  Future<dynamic> _fetchPackages() {
    _errorDescription = null;
    return NetworkManager.instance.getMyPackages(isPudo: true).then((response) {
      return response;
    }).catchError(
      (onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError),
    );
  }

  _onPackageCard(PackageSummary package) {
    if (widget.isOnReceivePack) {
      Navigator.pop(context, package);
    } else {
      NetworkManager.instance.getPackageDetails(packageId: package.packageId).then(
        (response) {
          if (response is PudoPackage) {
            Navigator.of(context).pushNamed(Routes.packagePickup, arguments: response);
          } else {
            SAAlertDialog.displayAlertWithClose(
              context,
              'genericErrorTitle'.localized(context, 'general'),
              'unknownDescription'.localized(context, 'general'),
            );
          }
        },
      ).catchError(
        (onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError),
      );
    }
  }

  bool _handlePackageSearch(String search, PackageSummary package) {
    if (search.isEmpty) {
      return true;
    }
    List<String> splittedSearch = search.toLowerCase().split(" ");
    String plainName = (package.packageName ?? "").toLowerCase();
    //Search by name
    for (String splitSearch in splittedSearch) {
      if (plainName.contains(splitSearch)) {
        return true;
      }
    }
    //Search by id
    for (String splitSearch in splittedSearch) {
      if ("ac${package.userId ?? 0}".contains(splitSearch)) {
        return true;
      }
    }
    //Search by userName
    if (package.firstName != null && package.lastName != null) {
      String fullName = "${package.firstName} ${package.lastName}";
      List<String> splittedName = fullName.toLowerCase().split(" ");
      for (String splitSearch in splittedSearch) {
        for (String splitName in splittedName) {
          if (splitName.contains(splitSearch)) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
