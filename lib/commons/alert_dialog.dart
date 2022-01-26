//
//  AlertDialog.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 28/02/2020.
//  Copyright © 2020 Sofapps. All rights reserved.
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

  static displayAlertWithButtons(BuildContext context, String title,
      String description, List<MaterialButton> actions) {
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
              return SAAlertDialog(
                  title: title,
                  description: HtmlUnescape().convert(description),
                  actions: modifiedActions);
            },
            context: context)
        .then((value) {
      isAlreadyShown = false;
    });
  }

  static displayAlertWithClose(
      BuildContext context, String title, dynamic description) {
    if (isAlreadyShown) {
      return;
    }
    isAlreadyShown = true;
    showDialog(
            builder: (subContext) {
              return SAAlertDialog(
                  title: title,
                  description: (description is OPBaseResponse)
                      ? HtmlUnescape()
                          .convert(description.message ?? "General error")
                      : (description is Error)
                          ? HtmlUnescape().convert(description.toString())
                          : (description is ErrorDescription)
                              ? HtmlUnescape()
                                  .convert(description.value.first.toString())
                              : HtmlUnescape().convert(description),
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
      title: Text(title),
      content: Text(description),
      actions: actions,
    );
  }
}
