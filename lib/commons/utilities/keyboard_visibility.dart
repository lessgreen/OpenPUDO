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

class KeyboardVisibilityBuilder extends StatefulWidget {
  final Widget? child;
  final Widget Function(
    BuildContext context,
    Widget? child,
    bool isKeyboardVisible,
  ) builder;

  const KeyboardVisibilityBuilder({
    Key? key,
    this.child,
    required this.builder,
  }) : super(key: key);

  @override
  _KeyboardVisibilityBuilderState createState() => _KeyboardVisibilityBuilderState();
}

class _KeyboardVisibilityBuilderState extends State<KeyboardVisibilityBuilder> with WidgetsBindingObserver {
  var _isKeyboardVisible = WidgetsBinding.instance!.window.viewInsets.bottom > 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance!.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        widget.child,
        _isKeyboardVisible,
      );
}
