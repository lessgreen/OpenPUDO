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
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/view_models/content_packages_list_user_page_viewmodel.dart';
import 'package:qui_green/widgets/error_screen_widget.dart';
import 'package:qui_green/widgets/listview_header.dart';
import 'package:qui_green/widgets/package_tile.dart';

class ContentPackagesListUserPage extends StatefulWidget {
  const ContentPackagesListUserPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ContentPackagesListUserPage> createState() => _ContentPackagesListUserPageState();
}

class _ContentPackagesListUserPageState extends State<ContentPackagesListUserPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContentPackagesListUserPageViewModel>(
        create: (_) => ContentPackagesListUserPageViewModel(context),
        child: Consumer<ContentPackagesListUserPageViewModel>(builder: (context, viewModel, _) {
          return RefreshIndicator(
            onRefresh: () async => viewModel.refreshDidTriggered(),
            child: viewModel.errorDescription != null
                ? ErrorScreenWidget(
                    description: viewModel.errorDescription,
                  )
                : Column(
                    children: [
                      CupertinoTextField(
                        placeholder: 'searchByName'.localized(context, 'general'),
                        padding: const EdgeInsets.all(Dimension.padding),
                        prefix: Padding(
                          padding: const EdgeInsets.only(left: Dimension.padding),
                          child: Icon(
                            CupertinoIcons.search,
                            color: viewModel.searchedValue.isEmpty ? AppColors.colorGrey : AppColors.primaryColorDark,
                          ),
                        ),
                        placeholderStyle: const TextStyle(color: AppColors.colorGrey),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimension.borderRadiusSearch)),
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        onChanged: (newValue) {
                          viewModel.searchedValue = newValue;
                        },
                      ),
                      Expanded(
                        child: ListViewHeader(
                          hasScrollbar: true,
                          scrollController: viewModel.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: viewModel.filteredPackagesList.length,
                          contentBuilder: (BuildContext context, int index) {
                            return PackageTile(
                              onTap: (PackageSummary package) {
                                viewModel.onPackageCard(viewModel.filteredPackagesList[index]);
                              },
                              packageSummary: viewModel.filteredPackagesList[index],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          );
        }));
  }
}
