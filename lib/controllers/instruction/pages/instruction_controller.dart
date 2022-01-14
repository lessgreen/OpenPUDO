//
//   user_position_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Wed Jan 05 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/controllers/instruction/di/instruction_controller_providers.dart';
import 'package:qui_green/controllers/instruction/viewmodel/instruction_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

class InstructionController extends StatefulWidget {
  const InstructionController({Key? key}) : super(key: key);

  @override
  _InstructionControllerState createState() => _InstructionControllerState();
}

class _InstructionControllerState extends State<InstructionController> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: Dimension.paddingXS),
      height: 8.0,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryColorDark : Colors.grey.shade300,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: instructionControllerProviders,
        child: Consumer<InstructionControllerViewModel?>(
            builder: (_, viewModel, __) {
          return KeyboardVisibilityBuilder(
              builder: (context, child, isKeyboardVisible) {
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
                      child: Container(
                        child: PageView(
                          physics: ClampingScrollPhysics(),
                          controller: _pageController,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          children: [
                            Column(
                              children: [
                                Center(
                                  child: Text(
                                    'É semplicissimo!',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    padding: EdgeInsets.only(
                                        left: Dimension.padding,
                                        right: Dimension.padding),
                                    child: Text(
                                      'Per poter ricevere il tuo pacco senza pensieri, utilizzando il tuo PUDO come destinatario ti basterà usare il seguente indirizzo di spedizione:',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),
                                    )),
                                SizedBox(
                                  height: 40,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _buildPageIndicator(),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: Dimension.paddingM,
                                      right: Dimension.paddingM),
                                  child: Container(
                                    padding: EdgeInsets.all(Dimension.padding),
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text('Destinatario:')),
                                        SizedBox(height: 10),
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Bar - La pinta AC12',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Via ippolito, 8',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              '21100 - Milano',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        SizedBox(height: 30)
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                Dimension.borderRadiusS))),
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                Container(
                                    padding: EdgeInsets.only(
                                        left: Dimension.padding,
                                        right: Dimension.padding),
                                    child: Text(
                                      'Se vuoi rivedere in seguito l’indirizzo da utilizzare per la consegna ti basterà selezionare il PUDO tra i tuoi PUDO dalla Home.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),
                                    )),
                              ],
                            ),
                            Column(
                              children: [
                                Center(
                                  child: Text(
                                    'Notifica in tempo reale',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    padding: EdgeInsets.only(
                                        left: Dimension.padding,
                                        right: Dimension.padding),
                                    child: Text(
                                      'Riceverai una notifica quando il tuo pacco sarà giunto a destinazione presso il tuo PUDO.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),
                                    )),
                                SizedBox(
                                  height: 40,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _buildPageIndicator(),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                SvgPicture.asset(ImageSrc.aboutYouArt,
                                    semanticsLabel: 'Art Background'),
                              ],
                            ),
                            Column(
                              children: [
                                Center(
                                  child: Text(
                                    'Notifica in tempo reale',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    padding: EdgeInsets.only(
                                        left: Dimension.padding,
                                        right: Dimension.padding),
                                    child: Text(
                                      'Riceverai una notifica quando il tuo pacco sarà giunto a destinazione presso il tuo PUDO.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),
                                    )),
                                SizedBox(
                                  height: 40,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _buildPageIndicator(),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                SvgPicture.asset(ImageSrc.aboutYouArt,
                                    semanticsLabel: 'Art Background'),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      crossFadeState: isKeyboardVisible
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      secondChild: const SizedBox(),
                      firstChild: MainButton(
                        onPressed: () => Navigator.of(context).pop(),
                        text: 'Vai alla home',
                      ),
                      duration: const Duration(milliseconds: 150),
                    ),
                  ],
                ),
              ),
            );
          });
        }));
  }
}
