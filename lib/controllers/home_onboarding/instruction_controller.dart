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
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/instruction_card.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/current_user.dart';

class HomeInstructionController extends StatefulWidget {
  final PudoProfile? pudoDataModel;
  const HomeInstructionController({Key? key, this.pudoDataModel})
      : super(key: key);

  @override
  _HomeInstructionControllerState createState() =>
      _HomeInstructionControllerState();
}

class _HomeInstructionControllerState extends State<HomeInstructionController> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  //TODO Once api in place structure this widget

  Widget _buildFirstPageWidget(String userId) => Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimension.padding),
            padding: const EdgeInsets.all(Dimension.padding),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    child: const Text('Destinatario:')),
                const SizedBox(height: 10),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${widget.pudoDataModel?.businessName ?? "n/a"} AC$userId',
                      style: const TextStyle(fontSize: 16),
                    )),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${widget.pudoDataModel?.address?.street ?? "n/a"} ${widget.pudoDataModel?.address?.streetNum ?? "n/a"}",
                      style: const TextStyle(fontSize: 16),
                    )),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${widget.pudoDataModel?.address?.zipCode ?? "n/a"} ${widget.pudoDataModel?.address?.city ?? "n/a"}",
                      style: const TextStyle(fontSize: 16),
                    )),
                const SizedBox(height: 30)
              ],
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(
                    Radius.circular(Dimension.borderRadiusS))),
          ),
          const SizedBox(
            height: Dimension.paddingM,
          ),
          Container(
              padding: const EdgeInsets.only(
                  left: Dimension.padding, right: Dimension.padding),
              child: const Text(
                'Se vuoi rivedere in seguito l’indirizzo da utilizzare per la consegna ti basterà selezionare il PUDO tra i tuoi PUDO dalla Home.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              )),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(
      builder: (_, currentUser, __) => CupertinoPageScaffold(
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
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  physics: const ClampingScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    InstructionCard(
                        title: "É semplicissimo!",
                        description:
                            'Per poter ricevere il tuo pacco senza pensieri, utilizzando il tuo PUDO come destinatario ti basterà usare il seguente indirizzo di spedizione:',
                        activeIndex: _currentPage,
                        pages: 2,
                        bottomWidget: _buildFirstPageWidget(
                            currentUser.user!.userId.toString())),
                    InstructionCard(
                        title: "Notifica in tempo reale",
                        description:
                            'Riceverai una notifica quando il tuo pacco sarà giunto a destinazione presso il tuo PUDO.',
                        activeIndex: _currentPage,
                        pages: 2,
                        bottomWidget: SvgPicture.asset(ImageSrc.aboutYouArt,
                            semanticsLabel: 'Art Background')),
                  ],
                ),
              ),
              MainButton(
                onPressed: () =>
                    Provider.of<CurrentUser>(context, listen: false).refresh(),
                text: 'Fine',
              ),
              // MainButton(
              //   onPressed: () => Navigator.of(context).pop(),
              //   text: 'Vai alla home',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
