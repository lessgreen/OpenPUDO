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
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

class PersonalDataBusinessController extends StatefulWidget {
  const PersonalDataBusinessController({Key? key}) : super(key: key);

  @override
  _PersonalDataBusinessControllerState createState() =>
      _PersonalDataBusinessControllerState();
}

class _PersonalDataBusinessControllerState
    extends State<PersonalDataBusinessController> {
  TextEditingController controller =
      TextEditingController(text: "+39-333-1234-567");

  @override
  Widget build(BuildContext context) {
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
              Center(
                child: Text(
                  'Qualche informazione sulla tua attività',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              const SizedBox(
                height: Dimension.paddingM,
              ),
              Container(
                  padding: const EdgeInsets.only(
                      left: Dimension.padding, right: Dimension.padding),
                  child: const Text(
                    'Per farti trovare dagli utenti dovresti dirci qualcosa in più della tua attività.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  )),
              const SizedBox(
                height: Dimension.paddingM,
              ),
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
                      Icons.apartment,
                      color: Colors.grey.shade400,
                      size: MediaQuery.of(context).size.width / 6,
                    ),
                    Text(
                      'Aggiungi una \ntua foto',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimension.padding),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: CupertinoTextField(
                  placeholder: 'Nome attività',
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).primaryColor))),
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  onChanged: (newValue) {},
                  onTap: () {
                    setState(() {});
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: CupertinoTextField(
                  placeholder: 'Inserisci il tuo indirizzo',
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).primaryColor))),
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  onChanged: (newValue) {},
                  onTap: () {
                    setState(() {});
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: CupertinoTextField(
                  placeholder: 'Telefono',
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).primaryColor))),
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  onChanged: (newValue) {},
                  onTap: () {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(
                    left: Dimension.padding, right: Dimension.padding),
                child: Text(
                  'Questo è il numero mostrato al pubblico. Se preferisci, puoi modificarlo.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const Spacer(),
              AnimatedCrossFade(
                crossFadeState: isKeyboardVisible
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                secondChild: const SizedBox(),
                firstChild: MainButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(Routes.exchange),
                  text: 'Avanti',
                ),
                duration: const Duration(milliseconds: 150),
              ),
            ],
          ),
        ),
      );
    });
  }
}
