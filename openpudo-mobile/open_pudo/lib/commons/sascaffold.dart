/*
 * sascaffold.dart
 * OpenPUDO
 * 
 * Created by Costantino Pistagna on 02/07/2021
 * Copyright Sofapps.it 2020/2021 - All rights reserved.
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundLoadingColor = (backgroundColor ?? Theme.of(context).backgroundColor).withAlpha(120);
    return isLoading != null
        ? ValueListenableBuilder(
            valueListenable: isLoading!,
            builder: (context, newValue, _) {
              return Container(
                child: Stack(
                  children: [
                    Scaffold(
                      backgroundColor: backgroundColor ?? Theme.of(context).backgroundColor,
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
                        : SizedBox()
                  ],
                ),
              );
            },
          )
        : Container(
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: backgroundColor ?? Theme.of(context).backgroundColor,
                  bottomSheet: bottomSheet,
                  resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
                  appBar: appBar,
                  body: body,
                  floatingActionButton: floatingActionButton,
                ),
              ],
            ),
          );
  }
}
