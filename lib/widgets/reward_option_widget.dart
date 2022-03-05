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
import 'package:qui_green/models/extra_info.dart';
import 'package:qui_green/models/reward_option.dart';
import 'package:qui_green/resources/res.dart';

class RewardOptionWidget extends StatelessWidget {
  final int index;
  final bool hasTopPadding;
  final EdgeInsets edgeInsets;
  final dynamic viewModel;

  const RewardOptionWidget({
    Key? key,
    required this.index,
    this.viewModel,
    this.hasTopPadding = false,
    this.edgeInsets = const EdgeInsets.fromLTRB(8, 0, 8, 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RewardOption? dataSource = ((viewModel != null) && (index < viewModel!.dataSource.length)) ? viewModel!.dataSource[index] : null;
    return dataSource == null
        ? const SizedBox()
        : Padding(
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
                                dataSource.iconData,
                                color: (viewModel!.isExclusiveSelected)
                                    ? (dataSource.checked ?? false)
                                        ? AppColors.cardColor
                                        : AppColors.colorGrey
                                    : AppColors.cardColor,
                              ),
                            ),
                            const WidgetSpan(
                              child: SizedBox(
                                width: Dimension.paddingXS,
                              ),
                            ),
                            TextSpan(
                              text: dataSource.text,
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
                        value: dataSource.checked ?? false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onChanged: (bool? newValue) => viewModel!.onValueChange(index, newValue ?? false),
                        side: const BorderSide(color: AppColors.labelLightDark, width: 1.0),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: Container(
                    width: double.infinity,
                  ),
                  secondChild: ExtraInfoWidget(
                    extraInfo: dataSource.extraInfo,
                    viewModel: viewModel,
                    index: index,
                  ),
                  crossFadeState: (dataSource.checked ?? false) && dataSource.extraInfo != null ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 100),
                ),
                Padding(
                  padding: EdgeInsets.only(top: edgeInsets.bottom),
                  child: const Divider(color: Colors.grey, height: 1),
                ),
              ],
            ),
          );
  }
}

class ExtraInfoWidget extends StatelessWidget {
  final dynamic viewModel;
  final ExtraInfo? extraInfo;
  final int index;
  final int? subIndex;

  const ExtraInfoWidget({
    Key? key,
    required this.index,
    this.subIndex,
    required this.extraInfo,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return extraInfo == null
        ? const SizedBox()
        : Container(
            margin: const EdgeInsets.all(Dimension.paddingS),
            padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
            decoration: (extraInfo!.type == ExtraInfoType.text || extraInfo!.type == ExtraInfoType.decimal)
                ? BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(Dimension.borderRadiusS))
                : null,
            child: extraInfo!.type == ExtraInfoType.text
                ? ExtraInfoTextWidget(
                    extraInfo: extraInfo!,
                    viewModel: viewModel!,
                    subIndex: subIndex,
                    index: index,
                  )
                : extraInfo!.type == ExtraInfoType.decimal
                    ? ExtraInfoDecimalWidget(
                        extraInfo: extraInfo!,
                        viewModel: viewModel!,
                        index: index,
                        subIndex: subIndex,
                      )
                    : extraInfo!.values != null && extraInfo!.type == ExtraInfoType.select && subIndex == null
                        ? ExtraInfoSelectWidget(
                            rowIndex: index,
                            extraInfo: extraInfo!,
                            viewModel: viewModel,
                          )
                        : const SizedBox(),
          );
  }
}

class ExtraInfoSelectWidget extends StatelessWidget {
  const ExtraInfoSelectWidget({
    Key? key,
    required this.rowIndex,
    required this.extraInfo,
    required this.viewModel,
  }) : super(key: key);

  final int rowIndex;
  final ExtraInfo extraInfo;
  final dynamic viewModel;

  @override
  Widget build(BuildContext context) {
    List<ExtraInfoSelectItem>? dataSource;
    if ((viewModel != null) && (rowIndex < viewModel!.dataSource.length) && viewModel!.dataSource[rowIndex].extraInfo != null && viewModel!.dataSource[rowIndex].extraInfo!.values != null) {
      dataSource = viewModel!.dataSource[rowIndex].extraInfo!.values;
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: dataSource?.length,
      itemBuilder: (context, index) {
        return ExtraInfoOptionWidget(
          rowIndex: rowIndex,
          index: index,
          viewModel: viewModel,
          hasTopPadding: index == 0,
        );
      },
    );
  }
}

class ExtraInfoOptionWidget extends StatelessWidget {
  final int rowIndex;
  final int index;
  final bool hasTopPadding;
  final EdgeInsets edgeInsets;
  final dynamic viewModel;

  const ExtraInfoOptionWidget({
    Key? key,
    required this.rowIndex,
    required this.index,
    this.viewModel,
    this.hasTopPadding = false,
    this.edgeInsets = const EdgeInsets.fromLTRB(8, 0, 8, 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ExtraInfoSelectItem>? dataSource;
    ExtraInfoSelectItem? currentItem;
    if ((viewModel != null) && (rowIndex < viewModel!.dataSource.length) && viewModel!.dataSource[rowIndex].extraInfo != null && viewModel!.dataSource[rowIndex].extraInfo!.values != null) {
      dataSource = viewModel!.dataSource[rowIndex].extraInfo!.values;
      if (dataSource != null && index < dataSource.length) {
        currentItem = dataSource[index];
      }
    }
    return dataSource == null || currentItem == null
        ? const SizedBox()
        : Padding(
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
                      child: Text(
                        currentItem.text,
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 15, fontWeight: FontWeight.w300, letterSpacing: 0),
                      ),
                    ),
                    Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        activeColor: AppColors.primaryColorDark,
                        value: currentItem.checked,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onChanged: (bool? newValue) => viewModel!.onSubSelectValueChange(rowIndex, index, newValue ?? false),
                        side: const BorderSide(color: AppColors.labelLightDark, width: 1.0),
                      ),
                    ),
                  ],
                ),
                (currentItem.checked ?? false) && currentItem.extraInfo != null
                    ? ExtraInfoWidget(
                        extraInfo: currentItem.extraInfo,
                        viewModel: viewModel,
                        subIndex: index,
                        index: rowIndex,
                      )
                    : Container(
                        width: double.infinity,
                      ),
                Padding(
                  padding: EdgeInsets.only(top: edgeInsets.bottom),
                  child: const Divider(color: Colors.grey, height: 1),
                ),
              ],
            ),
          );
  }
}

class ExtraInfoTextWidget extends StatelessWidget {
  const ExtraInfoTextWidget({
    Key? key,
    required this.extraInfo,
    required this.viewModel,
    required this.index,
    this.subIndex,
  }) : super(key: key);

  final ExtraInfo extraInfo;
  final dynamic viewModel;
  final int index;
  final int? subIndex;

  @override
  Widget build(BuildContext context) {
    var textValue = (extraInfo.value != null && extraInfo.value is String) ? extraInfo.value : "";
    final TextEditingController _textController = TextEditingController()
      ..text = textValue
      ..selection = TextSelection.collapsed(offset: textValue.length);

    return Focus(
      onFocusChange: (value) {
        if (value == false) {
          if (subIndex != null) {
            viewModel.onSubTextChange(index, subIndex!, _textController.text);
          } else {
            viewModel.onTextChange(index, _textController.text);
          }
        } else {
          _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
        }
      },
      child: TextFormField(
        scrollPadding: const EdgeInsets.only(bottom: 100),
        controller: _textController,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: extraInfo.text,
          hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class ExtraInfoDecimalWidget extends StatefulWidget {
  const ExtraInfoDecimalWidget({
    Key? key,
    required this.extraInfo,
    required this.viewModel,
    required this.index,
    this.subIndex,
  }) : super(key: key);

  final ExtraInfo extraInfo;
  final dynamic viewModel;
  final int index;
  final int? subIndex;

  @override
  State<ExtraInfoDecimalWidget> createState() => _ExtraInfoDecimalWidgetState();
}

class _ExtraInfoDecimalWidgetState extends State<ExtraInfoDecimalWidget> {
  var _hasFocus = false;
  final TextEditingController _textController = TextEditingController();

  dynamic validate(String? newValue) {
    if (_hasFocus == false) {
      return null;
    }
    try {
      if (newValue == null) {
        return "missing value";
      }
      var doubleValue = double.parse(newValue.replaceAll("€", ""));
      var step = (widget.extraInfo.step ?? 1.0);
      var min = widget.extraInfo.min;
      var max = widget.extraInfo.max;
      var scale = widget.extraInfo.scale?.toInt() ?? 1;

      double retValue = ((doubleValue / step).round()).toDouble() * step;
      if (min == null || max == null) {
        return retValue;
      } else if (retValue >= min && retValue <= max) {
        var tmpValue = double.parse(retValue.toStringAsFixed(scale));
        return tmpValue;
      } else {
        return "value out of range. should be [€$min - €$max]";
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var textValue = (widget.extraInfo.value != null && widget.extraInfo.value is String) ? widget.extraInfo.value : "";
    _textController
      ..text = textValue
      ..selection = TextSelection.collapsed(offset: textValue.length);
    return Focus(
      onFocusChange: (value) {
        if (value == false) {
          var retValue = validate(_textController.text);
          if (retValue is double) {
            if (widget.subIndex != null) {
              widget.viewModel.onSubTextChange(widget.index, widget.subIndex!, retValue.toString());
            } else {
              widget.viewModel.onTextChange(widget.index, retValue.toString());
            }
          }
        } else {
          _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
        }
        _hasFocus = value;
      },
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SizedBox(
          height: 70,
          child: TextFormField(
              scrollPadding: const EdgeInsets.only(bottom: 100),
              controller: _textController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyText2,
              decoration: InputDecoration(
                errorMaxLines: 1,
                hintText: widget.extraInfo.text,
                prefix: SizedBox(
                  width: 20,
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [Text('€')],
                  ),
                ),
                hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(fontStyle: FontStyle.italic),
                border: InputBorder.none,
              ),
              validator: (newValue) {
                var retValue = validate(newValue);
                if (retValue is double) {
                  return null;
                }
                return retValue;
              }),
        ),
      ),
    );
  }
}
