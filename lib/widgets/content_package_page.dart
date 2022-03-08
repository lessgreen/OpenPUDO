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
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/view_models/content_package_page_view_model.dart';
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

class _ContentPackagesPageState extends State<ContentPackagesPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContentPackagePageViewModel>(
      create: (_) => ContentPackagePageViewModel(context),
      child: Consumer<ContentPackagePageViewModel>(builder: (context, viewModel, _) {
        return RefreshIndicator(
          onRefresh: () async => viewModel.refreshDidTriggered(),
          child: viewModel.errorDescription != null
              ? ErrorScreenWidget(
                  description: viewModel.errorDescription,
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
                  itemCount: viewModel.availablePackages.length,
                  scrollController: viewModel.scrollController,
                  contentBuilder: (BuildContext context, int index) {
                    var currentPackage = viewModel.availablePackages[index];
                    return PackageCard(
                      dataSource: currentPackage,
                      stars: 0,
                      onTap: () => viewModel.onPackageCard(currentPackage),
                    );
                  },
                ),
        );
      }),
    );
  }
}
