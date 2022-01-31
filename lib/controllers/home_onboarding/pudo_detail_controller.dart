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
import 'package:flutter/services.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/widgets/text_field_button.dart';
import 'package:qui_green/models/pudo_detail_controller_data_model.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/resources/res.dart';

class HomePudoDetailController extends StatefulWidget {
  const HomePudoDetailController({Key? key, required this.dataModel})
      : super(key: key);
  final PudoDetailControllerDataModel dataModel;

  @override
  _HomePudoDetailControllerState createState() =>
      _HomePudoDetailControllerState();
}

class _HomePudoDetailControllerState extends State<HomePudoDetailController> {
  Widget _buildPudoDetail() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: Dimension.padding),
          Row(
            children: [
              Text(
                widget.dataModel.pudoProfile.businessName,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(
                width: Dimension.paddingS,
              ),
              Row(
                children: List<Widget>.generate(
                  (widget.dataModel.pudoProfile.ratingModel?.stars ?? 0) > 5
                      ? 5
                      : widget.dataModel.pudoProfile.ratingModel?.stars ?? 0,
                  (index) => Icon(
                    Icons.star_rounded,
                    color: Colors.yellow.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimension.paddingS),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              text: '',
              style: Theme.of(context).textTheme.bodyText2,
              children: [
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryColorDark,
                  ),
                ),
                const WidgetSpan(
                  child: SizedBox(
                    width: Dimension.paddingS,
                  ),
                ),
                TextSpan(
                    text: widget.dataModel.pudoProfile.address!.label ?? ""),
              ],
            ),
          ),
          if (widget.dataModel.pudoProfile.publicPhoneNumber != null)
            const SizedBox(height: Dimension.paddingS),
          if (widget.dataModel.pudoProfile.publicPhoneNumber != null)
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                text: '',
                style: Theme.of(context).textTheme.bodyText2,
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.phone,
                      color: AppColors.primaryColorDark,
                    ),
                  ),
                  const WidgetSpan(
                    child: SizedBox(
                      width: Dimension.paddingS,
                    ),
                  ),
                  TextSpan(
                      text:
                          widget.dataModel.pudoProfile.publicPhoneNumber ?? ""),
                ],
              ),
            ),
          const SizedBox(height: Dimension.paddingS),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              text: '',
              style: Theme.of(context).textTheme.bodyText2,
              children: [
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.people,
                    color: AppColors.primaryColorDark,
                  ),
                ),
                const WidgetSpan(
                  child: SizedBox(
                    width: Dimension.paddingS,
                  ),
                ),
                TextSpan(
                  text: (widget.dataModel.pudoProfile.customerCount ?? 0)
                      .toString(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const TextSpan(
                    text:
                        ' persone hanno già scelto quest’attività come punto di ritiro QuiGreen.'),
              ],
            ),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.all(0),
        brightness: Brightness.dark,
        backgroundColor: AppColors.primaryColorDark,
        middle: Text(
          '',
          style: Theme.of(context)
              .textTheme
              .headline6
              ?.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
        trailing: InkWell(
          onTap: goToRegistration,
          child: const Padding(
            padding: EdgeInsets.only(right: Dimension.padding),
            child: Text(
              'Scegli',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: Dimension.padding),
              alignment: Alignment.center,
              child: Column(
                children: [
                  AspectRatio(
                      aspectRatio: 18 / 9,
                      child: CustomNetworkImage(
                        url: widget.dataModel.pudoProfile.pudoPicId,
                        fit: BoxFit.cover,
                      )),
                  _buildPudoDetail(),
                  const SizedBox(height: Dimension.padding),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 1,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: Dimension.padding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info,
                        color: AppColors.primaryColorDark,
                      ),
                      const SizedBox(
                        width: Dimension.paddingS,
                      ),
                      Text(
                        'Per utilizzare QuiGreen in questo locale è richiesto:',
                        style: Theme.of(context).textTheme.caption?.copyWith(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w300,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3 * 2,
                    child: Text(
                      '“${widget.dataModel.pudoProfile.rewardMessage ?? ""}”',
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            height: 2,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goToRegistration() {
    Navigator.of(context).pushReplacementNamed(
      Routes.registrationComplete,
      arguments: widget.dataModel.pudoProfile,
    );
  }
}
