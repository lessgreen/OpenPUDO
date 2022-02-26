// ignore_for_file: invalid_use_of_protected_member

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
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/utilities/network_error_helper.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/listview_header.dart';
import 'package:qui_green/widgets/package_card.dart';
import 'package:qui_green/widgets/sascaffold.dart';

class HomeUserPackages extends StatefulWidget {
  const HomeUserPackages({Key? key}) : super(key: key);

  @override
  _HomeUserPackagesState createState() => _HomeUserPackagesState();
}

enum HomeUserState { hasPackages, noPackages, noPudo, unknown }

class _HomeUserPackagesState extends State<HomeUserPackages> with ConnectionAware {
  final ScrollController _scrollController = ScrollController();
  bool _canFetchMore = true;
  final int _fetchLimit = 20;
  List<PackageSummary> availablePackages = [];
  bool _hasPackages = false;
  bool _hasPudos = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (_, currentUser, __) {
        return FutureBuilder<HomeUserState>(
          future: _initPage(),
          initialData: HomeUserState.unknown,
          builder: (context, snapshot) => Material(
            child: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBarFix.build(
                context,
                middle: Text(
                  'QuiGreen',
                  style: Theme.of(context).textTheme.navBarTitle,
                ),
              ),
              child: SafeArea(
                child: SAScaffold(
                  isLoading: NetworkManager.instance.networkActivity,
                  body: RefreshIndicator(
                    onRefresh: () async => currentUser.triggerReload(),
                    child: _buildCorrectPage(snapshot.data),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //MARK: Build widget accessories

  Widget _buildNoPudos() => LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              child: Column(
                children: [
                  Flexible(
                    flex: 2,
                    child: Center(
                      child: Text(
                        'Non hai ancora aggiunto un pudo\nper le tue consegne!',
                        style: Theme.of(context).textTheme.bodyTextLight,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 6,
                    child: Opacity(opacity: 0.5, child: SvgPicture.asset(ImageSrc.noPudoYet)),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
          );
        },
      );

  Widget _buildNoPackages() => LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              child: Column(
                children: [
                  Flexible(
                    flex: 2,
                    child: Center(
                      child: Text(
                        'Non ci sono ancora consegne\nin attesa per te!',
                        style: Theme.of(context).textTheme.bodyTextLight,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 6,
                    child: Opacity(opacity: 0.5, child: SvgPicture.asset(ImageSrc.noPackagesYet)),
                  ),
                ],
              ),
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
          );
        },
      );

  Widget _buildPackages() => ListViewHeader(
        physics: const AlwaysScrollableScrollPhysics(),
        itemPadding: const EdgeInsets.only(bottom: Dimension.paddingS),
        title: 'I tuoi pacchi:',
        endText: '',
        itemCount: availablePackages.length,
        scrollController: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          return PackageCard(
            name: availablePackages[index].businessName ?? '',
            address: availablePackages[index].label ?? '',
            //TODO no pudo rating on PackageSummary
            stars: 0,
            onTap: () => _onPackageCard(availablePackages[index]),
            isRead: true,
            deliveryDate: availablePackages[index].createTms,
            image: availablePackages[index].packagePicId,
          );
        },
      );

  Widget _buildCorrectPage(HomeUserState? state) {
    switch (state) {
      case HomeUserState.hasPackages:
        return _buildPackages();
      case HomeUserState.noPackages:
        return _buildNoPackages();
      case HomeUserState.noPudo:
        return _buildNoPudos();
      default:
        return const SizedBox();
    }
  }

  //MARK: Actions

  void _onPackageCard(PackageSummary package) {
    NetworkManager.instance.getPackageDetails(packageId: package.packageId).then(
      (response) {
        if (response is PudoPackage) {
          Navigator.of(context).pushNamed(Routes.packagePickup, arguments: response);
        } else {
          SAAlertDialog.displayAlertWithClose(context, "Error", "Qualcosa e' andato storto");
        }
      },
    ).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  Future _fetchPackages() {
    return NetworkManager.instance.getMyPackages(limit: _fetchLimit, offset: availablePackages.length).then((value) {
      if (value is List<PackageSummary>) {
        availablePackages.addAll(value);
        didChangeDependencies();
        if (value.length < _fetchLimit) {
          _canFetchMore = false;
        }
      } else {
        NetworkErrorHelper.helper(context, value);
      }
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  Future<HomeUserState> _initPage() async {
    _canFetchMore = true;
    availablePackages.clear();
    _hasPackages = (Provider.of<CurrentUser>(context, listen: false).user?.packageCount ?? 0) > 0;
    _hasPudos = await NetworkManager.instance.getMyPudos().then((value) => (value as List).isNotEmpty).catchError((onError) => false);

    if (_hasPackages) {
      await _fetchPackages();
      if (!_scrollController.hasListeners) {
        _scrollController.addListener(_scrollListener);
      } else {
        _scrollController.removeListener(_scrollListener);
      }
    }

    if (_hasPackages) {
      return HomeUserState.hasPackages;
    } else if (_hasPudos) {
      return HomeUserState.noPackages;
    } else if (!_hasPudos) {
      return HomeUserState.noPudo;
    }
    return HomeUserState.unknown;
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0 && !NetworkManager.instance.networkActivity.value && _canFetchMore) {
        _fetchPackages();
      }
    }
  }
}
