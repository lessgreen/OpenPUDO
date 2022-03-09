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
import 'package:html_unescape/html_unescape.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/error_screen_widget.dart';
import 'package:qui_green/widgets/listview_header.dart';
import 'package:qui_green/widgets/package_card.dart';

class ContentPackagesPage extends StatefulWidget {
  const ContentPackagesPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ContentPackagesPage> createState() => _ContentPackagesPageState();
}

class _ContentPackagesPageState extends State<ContentPackagesPage> with ChangeNotifier {
  final ScrollController _scrollController = ScrollController();
  bool _canFetchMore = true;
  final int _fetchLimit = 20;
  List<PackageSummary> _availablePackages = [];
  String? _errorDescription;

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
              itemPadding: const EdgeInsets.only(
                top: Dimension.paddingS,
                bottom: Dimension.paddingS,
              ),
              title: 'I tuoi pacchi:'.toUpperCase(),
              titleStyle: Theme.of(context).textTheme.headerTitle,
              itemCount: _availablePackages.length,
              scrollController: _scrollController,
              contentBuilder: (BuildContext context, int index) {
                var currentPackage = _availablePackages[index];
                return PackageCard(
                  dataSource: currentPackage,
                  stars: 0,
                  onTap: () => _onPackageCard(currentPackage),
                );
              },
            ),
    );
  }

  Future<dynamic> _fetchPackages({bool? appendMode = false}) {
    _errorDescription = null;
    return NetworkManager.instance.getMyPackages(limit: _fetchLimit, offset: _availablePackages.length).then((response) {
      if (response is List<PackageSummary>) {
        _canFetchMore = (response.length == _fetchLimit);
        if (!_scrollController.hasListeners) {
          _scrollController.addListener(_scrollListener);
        }
      } else if (appendMode == false) {
        if (response is ErrorDescription) {
          _errorDescription = HtmlUnescape().convert(response.value.first.toString());
        } else {
          _errorDescription = "Ops!, qualcosa è andato storto";
        }
      }
      return response;
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  _onPackageCard(PackageSummary package) async {
    if (package.packageStatus == PackageStatus.notifySent) {
      await NetworkManager.instance.changePackageStatus(packageId: package.packageId, newStatus: PackageStatus.notified).then((value) {
        if (value is! PudoPackage) {
          SAAlertDialog.displayAlertWithClose(context, "Error", value, barrierDismissable: false);
        }
      }).catchError((onError) {
        SAAlertDialog.displayAlertWithClose(context, "Error", onError, barrierDismissable: false);
      });
    }
    NetworkManager.instance.getPackageDetails(packageId: package.packageId).then(
      (response) {
        if (response is PudoPackage) {
          Navigator.of(context).pushNamed(Routes.packagePickup, arguments: response).then(
                (value) => _refreshDidTriggered(),
              );
        } else {
          SAAlertDialog.displayAlertWithClose(context, "Error", "Ops!, Qualcosa e' andato storto");
        }
      },
    ).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0 && !NetworkManager.instance.networkActivity.value && _canFetchMore) {
        _fetchPackages(appendMode: true).then(
          (response) {
            if (response is List<PackageSummary>) {
              setState(() {
                _availablePackages.addAll(response);
              });
            }
          },
        );
      }
    }
  }
}
