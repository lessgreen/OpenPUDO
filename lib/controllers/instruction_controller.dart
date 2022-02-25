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
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/instruction_card.dart';
import 'package:qui_green/widgets/main_button.dart';
import 'package:qui_green/widgets/profile_pic_box.dart';
import 'package:qui_green/widgets/table_view_cell.dart';

class InstructionController extends StatefulWidget {
  const InstructionController({Key? key, this.pudoDataModel, required this.useCupertinoScaffold, required this.canGoBack, this.isForPudo = false}) : super(key: key);
  final bool useCupertinoScaffold;
  final PudoProfile? pudoDataModel;
  final bool canGoBack;
  final bool isForPudo;

  @override
  _InstructionControllerState createState() => _InstructionControllerState();
}

class _InstructionControllerState extends State<InstructionController> with ConnectionAware {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  //TODO Once api in place structure this widget

  Widget _buildFirstPageWidget(String userId) => Column(
        children: [
          if (widget.isForPudo) const Spacer(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimension.padding),
            padding: const EdgeInsets.all(Dimension.padding),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(alignment: Alignment.centerLeft, child: const Text('Destinatario:')),
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
                borderRadius: const BorderRadius.all(Radius.circular(Dimension.borderRadiusS))),
          ),
          if (widget.isForPudo) const Spacer(),
          if (!widget.isForPudo)
            const SizedBox(
              height: Dimension.paddingM,
            ),
          if (!widget.isForPudo)
            Container(
                padding: const EdgeInsets.only(left: Dimension.padding, right: Dimension.padding),
                child: const Text(
                  'Se vuoi rivedere in seguito l’indirizzo da utilizzare per la consegna ti basterà selezionare il PUDO tra i tuoi PUDO dalla Home.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                )),
        ],
      );

  Widget _buildPageWithCupertinoScaffold(CurrentUser currentUser) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            padding: const EdgeInsetsDirectional.all(0),
            brightness: Brightness.dark,
            backgroundColor: AppColors.primaryColorDark,
            middle: Text(
              'Istruzioni',
              style: Theme.of(context).textTheme.navBarTitle,
            ),
            leading: widget.canGoBack
                ? CupertinoNavigationBarBackButton(
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : const SizedBox()),
        child: _buildBody(currentUser),
      );

  Widget _buildPageWithBaseScaffold(CurrentUser currentUser) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: widget.canGoBack
              ? CupertinoNavigationBarBackButton(
                  color: AppColors.primaryColorDark,
                  onPressed: () => Navigator.of(context).pop(),
                )
              : const SizedBox(),
        ),
        body: _buildBody(currentUser),
      );

  Widget _buildBody(CurrentUser currentUser) => SafeArea(
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
                children: widget.isForPudo
                    ? [
                        InstructionCard(
                            indicatorOnTop: false,
                            title: "É semplicissimo!",
                            description: 'Quando i tuoi clienti invieranno un pacco verso la tua attività, riceverai un destinatario simile a quello riportato sotto.',
                            activeIndex: _currentPage,
                            pages: 4,
                            bottomWidget: _buildFirstPageWidget("12")),
                        InstructionCard(
                            indicatorOnTop: false,
                            title: "Gestisci la ricezione del pacco",
                            description: 'Ti basterà scegliere la voce:',
                            activeIndex: _currentPage,
                            pages: 4,
                            bottomWidget: Column(
                              children: [
                                TableViewCell(
                                  title: "Ho ricevuto un pacco",
                                  showTrailingChevron: true,
                                  showTopDivider: true,
                                  leading: SvgPicture.asset(
                                    ImageSrc.packReceivedLeadingIcon,
                                    color: AppColors.cardColor,
                                    width: 36,
                                    height: 36,
                                  ),
                                ),
                                const SizedBox(height: Dimension.paddingM),
                                Container(
                                  width: MediaQuery.of(context).size.width / 3 * 2,
                                  alignment: Alignment.center,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(style: Theme.of(context).textTheme.subtitle1, children: const [
                                      TextSpan(text: "dal menù principale dell'app\n"),
                                      TextSpan(text: "QuiGreen", style: TextStyle(color: AppColors.primaryColorDark)),
                                    ]),
                                  ),
                                ),
                              ],
                            )),
                        InstructionCard(
                            indicatorOnTop: false,
                            title: "Scegli il tuo utente",
                            description: 'Scegli il destinatario del pacco',
                            activeIndex: _currentPage,
                            pages: 4,
                            bottomWidget: Column(
                              children: [
                                TableViewCell(
                                  title: "Scegli un destinatario",
                                  showTopDivider: true,
                                  showTrailingChevron: true,
                                  leading: SvgPicture.asset(
                                    ImageSrc.profileArt,
                                    color: AppColors.cardColor,
                                    width: 36,
                                    height: 36,
                                  ),
                                ),
                                const SizedBox(height: Dimension.paddingM),
                                Container(
                                  width: MediaQuery.of(context).size.width / 3 * 2,
                                  alignment: Alignment.center,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(style: Theme.of(context).textTheme.subtitle1, children: const [
                                      TextSpan(text: "tra quelli che hanno scelto la tua attività per la consegna "),
                                      TextSpan(text: "QuiGreen", style: TextStyle(color: AppColors.primaryColorDark)),
                                    ]),
                                  ),
                                ),
                              ],
                            )),
                        InstructionCard(
                            indicatorOnTop: false,
                            title: "Notificagli l'arrivo",
                            description: "Scatta una foto al pacco",
                            activeIndex: _currentPage,
                            pages: 4,
                            bottomWidget: Column(
                              children: [
                                const ProfilePicBox(
                                  title: "Scatta una foto\nal pacco",
                                  mainIconSvgAsset: ImageSrc.shipmentLeadingCell,
                                ),
                                const SizedBox(height: Dimension.paddingM),
                                Container(
                                  width: MediaQuery.of(context).size.width / 3 * 2,
                                  alignment: Alignment.center,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(style: Theme.of(context).textTheme.subtitle1, children: const [
                                      TextSpan(text: "et voilà!", style: TextStyle(color: AppColors.primaryColorDark)),
                                      TextSpan(text: ",il gioco è fatto!"),
                                    ]),
                                  ),
                                ),
                              ],
                            )),
                      ]
                    : [
                        InstructionCard(
                            title: "É semplicissimo!",
                            description: 'Per poter ricevere il tuo pacco senza pensieri, utilizzando il tuo PUDO come destinatario ti basterà usare il seguente indirizzo di spedizione:',
                            activeIndex: _currentPage,
                            pages: 2,
                            bottomWidget: _buildFirstPageWidget(currentUser.user!.userId.toString())),
                        InstructionCard(
                            title: "Notifica in tempo reale",
                            description: 'Riceverai una notifica quando il tuo pacco sarà giunto a destinazione presso il tuo PUDO.',
                            activeIndex: _currentPage,
                            pages: 2,
                            bottomWidget: SvgPicture.asset(ImageSrc.notificationVectorArt, semanticsLabel: 'Art Background')),
                      ],
              ),
            ),
            MainButton(
              onPressed: () => currentUser.refresh(),
              text: 'Vai alla home',
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(builder: (_, currentUser, __) {
      if (widget.canGoBack) {
        return widget.useCupertinoScaffold ? _buildPageWithCupertinoScaffold(currentUser) : _buildPageWithBaseScaffold(currentUser);
      }
      return WillPopScope(
        onWillPop: () async => false,
        child: widget.useCupertinoScaffold ? _buildPageWithCupertinoScaffold(currentUser) : _buildPageWithBaseScaffold(currentUser),
      );
    });
  }
}
