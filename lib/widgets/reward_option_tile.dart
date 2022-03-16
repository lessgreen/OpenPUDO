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
import 'package:qui_green/models/exhange_option_model.dart';
import 'package:qui_green/resources/res.dart';

class RewardOptionTile extends StatelessWidget {
  final bool hasTopPadding;
  final EdgeInsets edgeInsets;
  final bool value;
  final Function(bool) onSelect;
  final bool isNonMultipleActive;
  final ExchangeOptionModel model;
  final Function(String) onTextChange;

  const RewardOptionTile({
    Key? key,
    required this.value,
    required this.isNonMultipleActive,
    required this.onSelect,
    required this.model,
    required this.onTextChange,
    this.hasTopPadding = false,
    this.edgeInsets = const EdgeInsets.fromLTRB(8, 0, 8, 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: hasTopPadding ? EdgeInsets.fromLTRB(edgeInsets.left, edgeInsets.bottom, edgeInsets.right, edgeInsets.bottom) : edgeInsets,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: Dimension.paddingS,
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          model.icon,
                          color: AppColors.cardColor,
                        ),
                      ),
                      const WidgetSpan(
                        child: SizedBox(
                          width: Dimension.paddingXS,
                        ),
                      ),
                      TextSpan(
                        text: model.name,
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 15, fontWeight: FontWeight.w300, letterSpacing: 0),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.scale(
                scale: 1.3,
                child: Checkbox(
                  activeColor: AppColors.primaryColorDark,
                  value: value,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  onChanged: isNonMultipleActive ? null : (bool? val) => onSelect(val ?? false),
                  side: const BorderSide(color: AppColors.labelLightDark, width: 1.0),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
              firstChild: Container(
                width: double.infinity,
              ),
              secondChild: Container(
                margin: const EdgeInsets.all(Dimension.paddingS),
                padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(Dimension.borderRadiusS),
                ),
                child: TextFormField(
                  onChanged: (newVal) => onTextChange(newVal),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: model.hintText,
                    hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                    border: InputBorder.none,
                  ),
                ),
              ),
              crossFadeState: value && model.hasField ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 100)),
          Padding(
            padding: EdgeInsets.only(top: edgeInsets.bottom),
            child: const Divider(color: Colors.grey, height: 1),
          ),
        ],
      ),
    );
  }
}
