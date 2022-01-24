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
import 'package:qui_green/controllers/maps/widgets/pudo_map_card.dart';
import 'package:qui_green/controllers/registration_complete/viewmodel/registration_complete_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';

class RegistrationCompleteController extends StatefulWidget {
  const RegistrationCompleteController({Key? key}) : super(key: key);

  @override
  _RegistrationCompleteControllerState createState() =>
      _RegistrationCompleteControllerState();
}

class _RegistrationCompleteControllerState
    extends State<RegistrationCompleteController> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProxyProvider0<RegistrationCompleteControllerViewModel?>(
            create: (context) => RegistrationCompleteControllerViewModel(),
            update: (context, viewModel) => viewModel),],
        child: Consumer<RegistrationCompleteControllerViewModel?>(
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
                    Center(
                      child: Text(
                        'Fatto!',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 3 * 2,
                        child: Text(
                          'Adesso potrai usare questo indirizzo per farti inviare i tuoi pacchi in totale comodità!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              ?.copyWith(fontWeight: FontWeight.w400),
                        )),
                    const SizedBox(height: Dimension.paddingL),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: Dimension.padding, right: Dimension.padding),
                        child: PudoMapCard(
                          name: "Bar - La pinta",
                          address: "Via ippolito, 8",
                          stars: 3,
                          onTap: () {},
                          image:
                              'https://cdn.skuola.net/news_foto/2017/descrizione-bar.jpg',
                        )),
                    const SizedBox(height: Dimension.paddingL),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimension.padding),
                      child: RichText(
                        text: TextSpan(
                          text: '',
                          style: Theme.of(context).textTheme.bodyText1,
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: CupertinoSwitch(
                                  trackColor: Colors.grey.shade200,
                                  activeColor: AppColors.primaryColorDark,
                                  value: true,
                                  onChanged: (bool newValue) => {}),
                            ),
                            const WidgetSpan(
                              child: SizedBox(
                                width: Dimension.padding,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Permetti al pudo di contattarm nal mio numero telefonico in caso di comunicazioni inerenti i miei pacchi.',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      height: 1.5,
                                      letterSpacing: 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    MainButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimension.padding,
                      ),
                      onPressed: () => viewModel!.onInstructionsClick(context),
                      text: 'Vedi le istruzioni',
                    ),
                    const SizedBox(height: Dimension.padding),
                    AnimatedCrossFade(
                      crossFadeState: isKeyboardVisible
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      secondChild: const SizedBox(),
                      firstChild: MainButton(
                        onPressed: () => viewModel!.onOkClick(context),
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
