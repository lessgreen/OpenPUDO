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
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SAScaffold extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final ValueNotifier? isLoading;
  final bool extendBodyBehindAppBar;

  const SAScaffold({
    Key? key,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    required this.appBar,
    required this.body,
    this.bottomSheet,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.isLoading,
    this.extendBodyBehindAppBar=false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundLoadingColor = Theme.of(context).cardColor.withAlpha(120);
    return isLoading != null
        ? ValueListenableBuilder(
            valueListenable: isLoading!,
            builder: (context, newValue, _) {
              return Stack(
                children: [
                  Scaffold(
                    backgroundColor: backgroundColor,
                    bottomSheet: bottomSheet,
                    resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
                    appBar: appBar,
                    body: body,
                    floatingActionButton: floatingActionButton,
                    floatingActionButtonLocation: floatingActionButtonLocation,
                  ),
                  newValue == true
                      ? Container(
                          color: backgroundLoadingColor,
                          child: SpinKitThreeBounce(
                            color: Theme.of(context).primaryColor,
                            size: 24.0,
                          ),
                        )
                      : const SizedBox()
                ],
              );
            },
          )
        : Stack(
            children: [
              Scaffold(
                extendBodyBehindAppBar: extendBodyBehindAppBar,
                backgroundColor: backgroundColor ?? Theme.of(context).backgroundColor,
                bottomSheet: bottomSheet,
                resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
                appBar: appBar,
                body: body,
                floatingActionButton: floatingActionButton,
              ),
            ],
          );
  }
}
