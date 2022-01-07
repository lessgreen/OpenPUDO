//
//   about_you_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Tue Jan 04 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class AboutYouController extends StatefulWidget {
  const AboutYouController({Key? key}) : super(key: key);

  @override
  _AboutYouControllerState createState() => _AboutYouControllerState();
}

class _AboutYouControllerState extends State<AboutYouController> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: const SizedBox(),
        ),
        body: Stack(
          children: [
            Center(
              child: SvgPicture.asset('assets/aboutYouArt.svg', semanticsLabel: 'Art Background'),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Raccontaci qualcosa su di te',
                      style: Theme.of(context).textTheme.headline6?.copyWith(letterSpacing: 0.6),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Sei qui per ricevere un pacco\no per fornire un servizio di ritiro?',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(const EdgeInsets.all(18)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(34.0),
                                  side: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                              ),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.bodyText2),
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)),
                          child: const Text('Voglio ricevere un pacco'),
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/userPosition');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(const EdgeInsets.all(18)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(34.0),
                                  side: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                              ),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.bodyText2),
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)),
                          child: const Text('Voglio fornire un servizio'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
