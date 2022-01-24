//
//   user_position_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Wed Jan 05 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/controllers/instruction/widgets/instruction_card.dart';
import 'package:qui_green/controllers/pudo_tutorial/viewmodel/pudo_tutorial_viewmodel.dart';
import 'package:qui_green/resources/res.dart';

class PudoTutorialController extends StatefulWidget {
  const PudoTutorialController({Key? key}) : super(key: key);

  @override
  _PudoTutorialControllerState createState() => _PudoTutorialControllerState();
}

class _PudoTutorialControllerState extends State<PudoTutorialController> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  //TODO Once api in place structure this widget
  Widget _buildFirstPageWidget() => Column(
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
                    child: const Text(
                      'Bar - La pinta AC12',
                      style: TextStyle(fontSize: 16),
                    )),
                Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Via ippolito, 8',
                      style: TextStyle(fontSize: 16),
                    )),
                Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      '21100 - Milano',
                      style: TextStyle(fontSize: 16),
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
        ],
      );

  //TODO Once api in place structure this widget
  Widget _buildSecondPageWidget() => Column(
        children: [
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(
                Icons.inbox,
                color: AppColors.cardColor,
              ),
              Text("Ho ricevuto un pacco"),
              Icon(
                Icons.keyboard_arrow_right,
                color: AppColors.cardColor,
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'dal menù principale dell\'app',
            style: TextStyle(fontSize: 18),
          ),
          const Text('QuiGreen',
              style: TextStyle(
                  color: AppColors.cardColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ],
      );

  Widget _buildThirdPageWidget() => Column(
        children: [
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(
                Icons.people,
                color: AppColors.cardColor,
              ),
              Text("Scegli destinatario"),
              Icon(
                Icons.keyboard_arrow_right,
                color: AppColors.cardColor,
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'tra quelli che hanno scelto la tua\nattività per la consegna ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const Text('QuiGreen',
              style: TextStyle(
                  color: AppColors.cardColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ],
      );

  Widget _buildFourPageWidget() => Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.width / 3,
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: const BorderRadius.all(
                    Radius.circular(Dimension.borderRadius))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.inbox,
                  color: Colors.grey.shade400,
                  size: MediaQuery.of(context).size.width / 6,
                ),
                Text(
                  'Aggiungi una \ntua foto',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('et voilà!',
                  style: TextStyle(
                      color: AppColors.cardColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              Text(
                ', il gioco è fatto!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProxyProvider0<PudoTutorialViewModel?>(
              create: (context) => PudoTutorialViewModel(),
              update: (context, viewModel) => viewModel),
        ],
        child: Consumer<PudoTutorialViewModel?>(builder: (_, viewModel, __) {
          return WillPopScope(
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
                                'Quanto i tuoi clienti invieranno un pacco verso la tua attivit , riceverai un destinatario simile a quello riportato sotto.',
                            activeIndex: _currentPage,
                            pages: 2,
                            bottomWidget: _buildFirstPageWidget()),
                        InstructionCard(
                            title: "Gesisci la ricezione del pacco",
                            description: 'Ti basterà scegliere la voce:',
                            activeIndex: _currentPage,
                            pages: 2,
                            bottomWidget: _buildSecondPageWidget()),
                        InstructionCard(
                            title: "Scegli il tuo utente",
                            description: 'Scegli il destinatario del pacco',
                            activeIndex: _currentPage,
                            pages: 3,
                            bottomWidget: _buildThirdPageWidget()),
                        InstructionCard(
                            title: "Notificagli l'arrivo",
                            description: 'Scatta una foto al pacco',
                            activeIndex: _currentPage,
                            pages: 4,
                            bottomWidget: _buildFourPageWidget()),
                      ],
                    ),
                  ),
                  MainButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Vai alla home',
                  ),
                ],
              ),
            ),
          );
        }));
  }
}
