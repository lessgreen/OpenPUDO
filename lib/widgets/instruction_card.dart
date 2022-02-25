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
import 'package:qui_green/resources/res.dart';

class InstructionCard extends StatelessWidget {
  final String title;
  final String description;
  final int activeIndex;
  final int pages;
  final Widget bottomWidget;
  final bool indicatorOnTop;
  const InstructionCard({Key? key, required this.title, required this.description, required this.activeIndex, required this.pages, required this.bottomWidget,this.indicatorOnTop = true}) : super(key: key);

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: Dimension.paddingXS),
      height: 8.0,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryColorDark : Colors.grey.shade300,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
          const SizedBox(
            height: Dimension.padding,
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                alignment: Alignment.center,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1,
                )),
          ),
          const SizedBox(
            height: Dimension.padding,
          ),
          if(indicatorOnTop)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(pages, (index) => index == activeIndex ? _indicator(true) : _indicator(false)),
          ),
          if(indicatorOnTop)
          const SizedBox(
            height: Dimension.padding,
          ),
          //child
          Expanded(
            flex: 7,
            child: bottomWidget,
          ),
          const SizedBox(
            height: Dimension.paddingL,
          ),
          if(!indicatorOnTop)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(pages, (index) => index == activeIndex ? _indicator(true) : _indicator(false)),
            ),
          if(!indicatorOnTop)
            const SizedBox(
              height: Dimension.paddingM,
            ),
        ],
      );
}
