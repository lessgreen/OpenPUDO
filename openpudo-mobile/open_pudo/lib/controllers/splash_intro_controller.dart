//
//  SplashIntroController.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:open_pudo/commons/sabutton.dart';
import 'package:open_pudo/main.dart';

class SplashIntroController extends StatefulWidget {
  const SplashIntroController({Key? key}) : super(key: key);

  @override
  _SplashIntroControllerState createState() => _SplashIntroControllerState();
}

class _SplashIntroControllerState extends State<SplashIntroController> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd() {
    sharedPreferences?.setBool('introShown', true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var bodyStyle = Theme.of(context).textTheme.bodyText1 ?? TextStyle(fontSize: 19.0);
    var titleTextStyle = Theme.of(context).textTheme.headline6 ?? TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700);

    var pageDecoration = PageDecoration(
      titleTextStyle: titleTextStyle,
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      globalFooter: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Text(
              'Salta e vai alla home',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: Theme.of(context).backgroundColor),
            ),
          ),
          onPressed: () => _onIntroEnd(),
        ),
      ),
      pages: [
        PageViewModel(
          titleWidget: AutoSizeText(
            "Benvenuto in QuiGreen",
            style: titleTextStyle,
            maxLines: 1,
          ),
          bodyWidget: AutoSizeText(
            "Ben fatto! Scaricando l’App QuiGreen hai fatto il primo passo verso una vita più felice e più green. Scopri il secondo passo!",
            style: bodyStyle,
            textAlign: TextAlign.center,
          ),
          image: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SvgPicture.asset('assets/heavyBox.svg'),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: AutoSizeText(
            "Secondo passo",
            style: titleTextStyle,
            maxLines: 1,
          ),
          bodyWidget: AutoSizeText(
            "Usa tutti i servizi QuiGreen in modo gratuito. Registrati, cerca i tuoi punti di ritiro preferiti, fai consegnare il pacco, ritiralo quando vuoi!",
            style: bodyStyle,
            textAlign: TextAlign.center,
          ),
          image: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SvgPicture.asset('assets/deliveries.svg'),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: AutoSizeText(
            "Cosa facciamo per te",
            style: titleTextStyle,
            maxLines: 1,
          ),
          bodyWidget: AutoSizeText(
            "Siamo felici di averti con noi! Usando la nostra App QuiGreen in modo totalmente gratuito ci aiuterai ad avere un mondo più green e con persone più felici!",
            style: bodyStyle,
            textAlign: TextAlign.center,
          ),
          image: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SvgPicture.asset('assets/orderDelivered.svg'),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: AutoSizeText(
            "Entra a far parte del cambiamento!",
            style: titleTextStyle,
            maxLines: 1,
          ),
          bodyWidget: SAButton(
              label: "Iniziamo",
              onPressed: () {
                _onIntroEnd();
              }),
          image: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SvgPicture.asset('assets/packageArrived.svg'),
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(),
      showDoneButton: false,
      showNextButton: true,
      skipFlex: 0,
      nextFlex: 0,
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeColor: Color(0xff95C11F),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
