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
import 'package:provider/provider.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/view_models/content_packages_list_pudo_history_viewmodel.dart';
import 'package:qui_green/widgets/error_screen_widget.dart';
import 'package:qui_green/widgets/listview_header.dart';
import 'package:qui_green/widgets/package_tile.dart';

class ContentPackagesListPudoHistory extends StatefulWidget {
  const ContentPackagesListPudoHistory({
    Key? key,
    required this.searchValue,
  }) : super(key: key);
  final String searchValue;

  @override
  State<ContentPackagesListPudoHistory> createState() => _ContentPackagesListPudoHistoryState();
}

class _ContentPackagesListPudoHistoryState extends State<ContentPackagesListPudoHistory> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContentPackagesListPudoHistoryViewModel>(
      create: (_) => ContentPackagesListPudoHistoryViewModel(context),
      child: Consumer<ContentPackagesListPudoHistoryViewModel>(builder: (context, viewModel, _) {
        List<PackageSummary> filteredPackages = _filteredPackagesList(viewModel);
        return RefreshIndicator(
          onRefresh: () async => viewModel.refreshDidTriggered(),
          child: viewModel.errorDescription != null
              ? ErrorScreenWidget(
                  description: viewModel.errorDescription,
                )
              : ListViewHeader(
                  hasScrollbar: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: filteredPackages.length,
                  scrollController: viewModel.scrollController,
                  contentBuilder: (BuildContext context, int index) {
                    return PackageTile(
                        onTap: (PackageSummary package) {
                          viewModel.onPackageCard(filteredPackages[index]);
                        },
                        packageSummary: filteredPackages[index]);
                  },
                ),
        );
      }),
    );
  }

  List<PackageSummary> _filteredPackagesList(ContentPackagesListPudoHistoryViewModel viewModel) =>
      viewModel.availablePackages.where((element) => viewModel.handlePackageSearch(widget.searchValue, element)).toList();
}
