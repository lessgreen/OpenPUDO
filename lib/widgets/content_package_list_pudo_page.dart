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
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/widgets/content_package_list_pudo.dart';
import 'package:qui_green/widgets/content_package_list_pudo_history.dart';

class ContentPackagesListPudoPage extends StatefulWidget {
  const ContentPackagesListPudoPage({Key? key, required this.enableHistory, required this.isOnReceivePack}) : super(key: key);
  final bool enableHistory;
  final bool isOnReceivePack;
  @override
  State<ContentPackagesListPudoPage> createState() => _ContentPackagesListPudoPageState();
}

class _ContentPackagesListPudoPageState extends State<ContentPackagesListPudoPage> {
  String _searchedValue = "";
  ContentPackagesListPudoPageState state = ContentPackagesListPudoPageState.open;
  bool _isHistoryToggleVisible = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                        if (state == ContentPackagesListPudoPageState.history) {
                          state = ContentPackagesListPudoPageState.open;
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
                      value: state == ContentPackagesListPudoPageState.history,
                      activeColor: AppColors.primaryColorDark,
                      onChanged: (newVal) {
                        if (newVal) {
                          setState(() {
                            state = ContentPackagesListPudoPageState.history;
                          });
                        } else {
                          setState(() {
                            state = ContentPackagesListPudoPageState.open;
                          });
                        }
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
        Expanded(child: _buildCorrectPage()),
      ],
    );
  }

  Widget _buildCorrectPage() {
    switch (state) {
      case ContentPackagesListPudoPageState.history:
        return ContentPackagesListPudoHistory(searchValue: _searchedValue);
      case ContentPackagesListPudoPageState.open:
        return ContentPackagesListPudo(
          searchValue: _searchedValue,
          isOnReceivePack: widget.isOnReceivePack,
        );
      default:
        return const SizedBox();
    }
  }
}

enum ContentPackagesListPudoPageState { open, history }
