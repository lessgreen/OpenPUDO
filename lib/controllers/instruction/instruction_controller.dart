//
//   user_position_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Wed Jan 05 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/controllers/instruction/widgets/instruction_card.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/singletons/current_user.dart';

class InstructionController extends StatefulWidget {
  const InstructionController({Key? key, this.pudoDataModel}) : super(key: key);
  final PudoProfile? pudoDataModel;

  @override
  _InstructionControllerState createState() => _InstructionControllerState();
}

class _InstructionControllerState extends State<InstructionController> {
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
                      '${widget.pudoDataModel?.businessName} AC$userId',
                      style: const TextStyle(fontSize: 16),
                    )),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${widget.pudoDataModel?.address?.street ?? " "} ${widget.pudoDataModel?.address?.streetNum ?? " "}",
                      style: const TextStyle(fontSize: 16),
                    )),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${widget.pudoDataModel?.address?.zipCode ?? " "} ${widget.pudoDataModel?.address?.city ?? " "}",
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
      builder: (_, currentUser, __) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            leading: const SizedBox(),
          ),
          body: Column(
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
