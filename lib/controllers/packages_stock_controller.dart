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
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/cupertino_navigation_bar_fix.dart';
import 'package:qui_green/commons/utilities/date_time_extension.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/error_screen_widget.dart';
import 'package:qui_green/widgets/listview_header.dart';
import 'package:qui_green/widgets/sascaffold.dart';
import 'package:qui_green/widgets/table_view_cell.dart';

class PackagesStockController extends StatefulWidget {
  const PackagesStockController({Key? key, this.isOnReceivePack = false, this.enableSearch = true, this.enableHistory = false}) : super(key: key);
  final bool isOnReceivePack;
  final bool enableSearch;
  final bool enableHistory;

  @override
  _PackagesStockControllerState createState() => _PackagesStockControllerState();
}

class _PackagesStockControllerState extends State<PackagesStockController> {
  List<PackageSummary>? _availablePackages;
  bool _isHistoryToggleVisible = false;

  List<PackageSummary> get _filteredUsersList => _availablePackages != null ? _availablePackages!.where((element) => _handlePackageSearch(_searchedValue, element)).toList() : [];

  String _searchedValue = "";

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
    _availablePackages = null;
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
    return Consumer<CurrentUser>(
      builder: (context, currentUser, _) => Material(
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBarFix.build(
            context,
            middle: Text(
              widget.isOnReceivePack ? 'Scegli un pacco' : "Pacchi in giacenza",
              style: Theme.of(context).textTheme.navBarTitle,
            ),
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          //ClipPath is used to avoid the scrolling cards to go outside the screen
          //and being visible when popping the page
          child: ClipPath(
            child: SAScaffold(
              isLoading: NetworkManager.instance.networkActivity,
              body: Column(
                children: [
                  if (widget.enableSearch)
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            placeholder: 'Cerca per nome',
                            padding: const EdgeInsets.all(Dimension.padding),
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: Dimension.padding),
                              child: Icon(
                                CupertinoIcons.search,
                                color: _searchedValue.isEmpty ? AppColors.colorGrey : AppColors.primaryColorDark,
                              ),
                            ),
                            placeholderStyle: const TextStyle(color: AppColors.colorGrey),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimension.borderRadiusSearch)),
                            autofocus: false,
                            textInputAction: TextInputAction.done,
                            onChanged: (newValue) {
                              setState(() {
                                _searchedValue = newValue;
                              });
                            },
                          ),
                        ),
                        if (widget.enableHistory)
                          Padding(
                            padding: const EdgeInsets.only(right: Dimension.padding),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isHistoryToggleVisible = !_isHistoryToggleVisible;
                                  if (!_isHistoryToggleVisible) {
                                    if (_isHistory) {
                                      _isHistory = false;
                                      _refreshDidTriggered();
                                    }
                                  }
                                });
                              },
                              child: Icon(
                                CupertinoIcons.slider_horizontal_3,
                                size: 26,
                                color: _isHistoryToggleVisible ? AppColors.primaryColorDark : CupertinoColors.label,
                              ),
                            ),
                          )
                      ],
                    ),
                  AnimatedCrossFade(
                    crossFadeState: _isHistoryToggleVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 100),
                    firstChild: const SizedBox(
                      width: double.infinity,
                    ),
                    secondChild: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: Dimension.padding,
                            ),
                            const Text("Cerca tra lo storico dei dati", style: TextStyle(color: AppColors.colorGrey)),
                            const Spacer(),
                            CupertinoSwitch(
                                value: _isHistory,
                                activeColor: AppColors.primaryColorDark,
                                onChanged: (newVal) {
                                  setState(() {
                                    _isHistory = newVal;
                                  });
                                  _refreshDidTriggered();
                                }),
                            const SizedBox(
                              width: Dimension.padding,
                            ),
                          ],
                        ),
                        const Divider(
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: RefreshIndicator(
                    onRefresh: () async => _refreshDidTriggered(),
                    child: _errorDescription != null
                        ? ErrorScreenWidget(
                            description: _errorDescription,
                          )
                        : ListViewHeader(
                            hasScrollbar: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _filteredUsersList.length,
                            contentBuilder: (BuildContext context, int index) {
                              return TableViewCell(
                                onTap: () {
                                  if (widget.isOnReceivePack) {
                                    Navigator.pop(context, _filteredUsersList[index]);
                                  } else {
                                    _onPackageCard(_filteredUsersList[index]);
                                  }
                                },
                                fullWidth: true,
                                showTrailingChevron: true,
                                title: SizedBox(
                                    height: 40,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${_filteredUsersList[index].createTms!.ddmmyyyy} ${_filteredUsersList[index].packageName ?? ""}",
                                          style: Theme.of(context).textTheme.bodyTextBold,
                                        ),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(style: Theme.of(context).textTheme.bodyTextLight!.copyWith(color: CupertinoColors.secondaryLabel), children: [
                                            const TextSpan(text: "Destinatario: "),
                                            TextSpan(text: "AC${_filteredUsersList[index].userId}", style: Theme.of(context).textTheme.bodyTextBold),
                                          ]),
                                        ),
                                      ],
                                    )),
                              );
                            },
                          ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _onPackageCard(PackageSummary package) {
    NetworkManager.instance.getPackageDetails(packageId: package.packageId).then(
      (response) {
        if (response is PudoPackage) {
          Navigator.of(context).pushNamed(Routes.packagePickup, arguments: response);
        } else {
          SAAlertDialog.displayAlertWithClose(context, "Error", "Ops!, Qualcosa e' andato storto");
        }
      },
    ).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  bool _isHistory = false;

  //MARK: Actions

  Future<dynamic> _fetchPackages() {
    if (_availablePackages == null) {
      _errorDescription = null;
      return NetworkManager.instance.getMyPackages(enablePagination: false, isPudo: true, history: _isHistory).then((response) {
        if (response is ErrorDescription) {
          _errorDescription = HtmlUnescape().convert(response.value.first.toString());
        } else if (response is! List<PackageSummary>) {
          _errorDescription = "Ops!, qualcosa è andato storto";
        }
        return response;
      }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
    } else {
      return Future.value();
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
    return false;
  }
}
