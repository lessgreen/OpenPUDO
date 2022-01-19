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
import 'package:provider/provider.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/controllers/exchange/di/exchange_controller_providers.dart';
import 'package:qui_green/controllers/exchange/viewmodel/exchange_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';

class ExchangeController extends StatefulWidget {
  const ExchangeController({Key? key}) : super(key: key);

  @override
  _ExchangeControllerState createState() => _ExchangeControllerState();
}

class _ExchangeControllerState extends State<ExchangeController> {
  bool checkAssociati = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: exchangeControllerProviders,
        child:
            Consumer<ExchangeControllerViewModel?>(builder: (_, viewModel, __) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent));
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
                body: ListView(
                  children: [
                    Center(
                      child: Text(
                        'Desideri qualcosa in cambio?',
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
                          'Puoi decidere di fornire il servizio QuiGreen in maniera completamente gratuita oppure puoi essere pagato in uno dei seguenti modi:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey),
                        )),
                    const SizedBox(height: Dimension.padding),
                    const Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: Dimension.paddingS),
                          child: Icon(
                            Icons.emoji_emotions,
                            color: AppColors.cardColor,
                          ),
                        ),
                        Text(
                            "Gratis per tutti, basta un sorriso.\nLo facciamo insieme per l’ambiente!"),
                        Checkbox(
                          value: false,
                          shape: CircleBorder(),
                          onChanged: (bool? value) {},
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: Dimension.paddingS),
                          child: Icon(
                            Icons.emoji_emotions,
                            color: AppColors.cardColor,
                          ),
                        ),
                        Text("Gratis per i clienti abituali."),
                        Checkbox(
                          value: true,
                          shape: CircleBorder(),
                          onChanged: (bool? value) {},
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: Dimension.paddingS),
                          child: Icon(
                            Icons.credit_card,
                            color: AppColors.cardColor,
                          ),
                        ),
                        Text(
                            "Gratis per associati, abbonati o\npossessori di tessera fedeltà."),
                        Checkbox(
                          value: checkAssociati,
                          shape: CircleBorder(),
                          onChanged: (newValue) {
                            setState(() {
                              checkAssociati = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                    if (checkAssociati)
                      Padding(
                        padding: const EdgeInsets.all(Dimension.paddingS),
                        child: TextFormField(
                          maxLines: 5,
                          decoration: InputDecoration(
                              fillColor: Colors.grey,
                              labelText:
                                  'Se vuoi specifica che tipo di tessera o\nabbonamento sono necessari.'),
                        ),
                      ),
                    const Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: Dimension.paddingS),
                          child: Icon(
                            Icons.shopping_basket_rounded,
                            color: AppColors.cardColor,
                          ),
                        ),
                        Text(
                            "Acquisto di qualcosa o\nconsumazione al momento del ritiro."),
                        Checkbox(
                          value: false,
                          shape: CircleBorder(),
                          onChanged: (bool? value) {},
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: Dimension.paddingS),
                          child: Icon(
                            Icons.attach_money,
                            color: AppColors.cardColor,
                          ),
                        ),
                        Text("Pagamento del servizio per pacco\nritirato."),
                        Checkbox(
                          value: false,
                          shape: CircleBorder(),
                          onChanged: (bool? value) {},
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    Spacer(),
                    AnimatedCrossFade(
                      crossFadeState: isKeyboardVisible
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      secondChild: const SizedBox(),
                      firstChild: MainButton(
                        onPressed: () => viewModel!.onSendClick(context),
                        text: 'Avanti',
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
