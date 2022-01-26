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
import 'package:qui_green/view_models/insert_address_controller_viewmodel.dart';
import 'package:qui_green/models/address_model.dart';
import 'package:qui_green/resources/res.dart';

class AddressOverlay extends StatefulWidget {
  final InsertAddressControllerViewModel viewModel;
  final double positionTop;
  final double positionLeft;
  final double width;
  final Function(AddressModel) onSelect;
  final Function() removeOverlay;

  const AddressOverlay({Key? key, required this.viewModel, required this.positionTop, required this.positionLeft, required this.width, required this.removeOverlay, required this.onSelect})
      : super(key: key);

  @override
  State<AddressOverlay> createState() => _AddressOverlayState();
}

class _AddressOverlayState extends State<AddressOverlay> {
  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.addresses.isEmpty) {
      widget.removeOverlay();
    }
    return Positioned(
        left: widget.positionLeft,
        top: widget.positionTop,
        child: Material(
            elevation: 0,
            color: Colors.white.withOpacity(0.9),
            child: Container(
                alignment: Alignment.bottomRight,
                width: widget.width,
                height: (MediaQuery.of(context).size.height / 3),
                child: Padding(
                  padding: const EdgeInsets.all(Dimension.paddingS),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: widget.viewModel.addresses.map((e) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  onTap: () => widget.onSelect(e),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: Dimension.paddingXS,
                                      ),
                                      Text(e.label ?? ""),
                                      const SizedBox(
                                        height: Dimension.paddingXS,
                                      ),
                                    ],
                                  ))),
                          Divider(color: Colors.grey.shade400, height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                ))));
  }
}
