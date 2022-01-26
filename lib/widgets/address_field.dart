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
import 'package:latlong2/latlong.dart';
import 'package:qui_green/view_models/insert_address_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';

import 'address_overlay.dart';

class AddressField extends StatefulWidget {
  final InsertAddressControllerViewModel viewModel;
  final FocusNode node;

  const AddressField({Key? key, required this.viewModel, required this.node}) : super(key: key);

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  late OverlayEntry overlayEntry;
  bool overlayCreated = false;

  @override
  void dispose() {
    if (overlayCreated) {
      overlayEntry.remove();
    }
    super.dispose();
  }

  void removeOverlay() {
    overlayCreated = false;
    overlayEntry.remove();
  }

  void _showOverlay({required InsertAddressControllerViewModel viewModel, required BuildContext context, required double top, required double left, required double width}) async {
    if (!overlayCreated) {
      OverlayState? overlayState = Overlay.of(context);
      overlayEntry = OverlayEntry(builder: (context) {
        return AddressOverlay(
          viewModel: viewModel,
          positionLeft: left,
          positionTop: top,
          width: width,
          onSelect: (val) {
            viewModel.isSelectingFromOverlay = true;
            viewModel.hasSelected = true;
            viewModel.addressController.text = val.label!;
            viewModel.position = LatLng(val.lat!, val.lon!);
            Future.delayed(const Duration(milliseconds: 100), () => viewModel.isSelectingFromOverlay = false);
            removeOverlay();
          },
          removeOverlay: removeOverlay,
        );
      });
      overlayCreated = true;
      overlayState?.insert(overlayEntry);
    }
  }

  final GlobalKey _key = GlobalKey();

  void onAfter() {
    _key.currentContext?.size?.width;
    final RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;
    Offset? positionRed = renderBox.localToGlobal(Offset.zero);
    double top = (positionRed.dy) + (_key.currentContext?.size?.height ?? 0);
    _showOverlay(context: context, top: top + Dimension.paddingXS, width: _key.currentContext?.size?.width ?? 0, left: positionRed.dx, viewModel: widget.viewModel);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      key: _key,
      controller: widget.viewModel.addressController,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
      autofocus: false,
      focusNode: widget.node,
      textInputAction: TextInputAction.done,
      onChanged: (newValue) {
        if (!widget.viewModel.isSelectingFromOverlay) {
          widget.viewModel.hasSelected = false;
          widget.viewModel.onSearchChanged(newValue, onAfter);
        }
      },
    );
  }
}
