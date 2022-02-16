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

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/base_response.dart';

class SAAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> actions;
  static bool isAlreadyShown = false;

  const SAAlertDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.actions,
  }) : super(key: key);

  static displayAlertWithButtons(BuildContext context, String title, String description, List<MaterialButton> actions) {
    if (isAlreadyShown) {
      return;
    }
    isAlreadyShown = true;

    showDialog(
            builder: (subContext) {
              List<MaterialButton> modifiedActions = actions
                  .asMap()
                  .map((key, value) {
                    return MapEntry(
                      key,
                      MaterialButton(
                        elevation: 0,
                        child: value.child,
                        onPressed: () {
                          isAlreadyShown = false;
                          value.onPressed?.call();
                          if (Navigator.of(subContext).canPop() == true) {
                            Navigator.of(subContext).pop();
                          }
                        },
                      ),
                    );
                  })
                  .values
                  .toList();
              return SAAlertDialog(title: title, description: HtmlUnescape().convert(description), actions: modifiedActions);
            },
            context: context)
        .then((value) {
      isAlreadyShown = false;
    });
  }

  static displayAlertWithClose(BuildContext context, String title, dynamic description) {
    if (isAlreadyShown) {
      return;
    }
    isAlreadyShown = true;
    showDialog(
            builder: (subContext) {
              return SAAlertDialog(
                  title: title,
                  description: (description is OPBaseResponse)
                      ? HtmlUnescape().convert(description.message ?? "General error")
                      : (description is Error)
                          ? HtmlUnescape().convert(description.toString())
                          : (description is ErrorDescription)
                              ? HtmlUnescape().convert(description.value.first.toString())
                              : (description is SocketException)
                                  ? HtmlUnescape().convert(description.message)
                                  : (description is TimeoutException)
                                      ? HtmlUnescape().convert(description.message ?? "Timeout exception")
                                      : (description is String)
                                          ? HtmlUnescape().convert(description)
                                          : 'Unknown error occurred. Please try again',
                  actions: <Widget>[
                    MaterialButton(
                      elevation: 0,
                      child: Text(
                        'closeButton'.localized(context, 'alert'),
                      ),
                      onPressed: () {
                        isAlreadyShown = false;
                        Navigator.of(subContext).pop();
                      },
                    )
                  ]);
            },
            context: context)
        .then((value) {
      isAlreadyShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text(title)),
      content: Text(
        description,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: actions,
    );
  }
}
