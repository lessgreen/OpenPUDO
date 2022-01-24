//
//   user_position_controller.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Wed Jan 05 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/utilities/keyboard_visibility.dart';
import 'package:qui_green/commons/widgets/main_button.dart';
import 'package:qui_green/controllers/insert_address/viewmodel/insert_address_controller_viewmodel.dart';
import 'package:qui_green/controllers/insert_address/widgets/address_field.dart';
import 'package:qui_green/resources/res.dart';

class InsertAddressController extends StatefulWidget {
  const InsertAddressController({Key? key}) : super(key: key);

  @override
  _InsertAddressControllerState createState() =>
      _InsertAddressControllerState();
}

class _InsertAddressControllerState extends State<InsertAddressController> {
  final FocusNode _address = FocusNode();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProxyProvider0<InsertAddressControllerViewModel?>(
              create: (context) => InsertAddressControllerViewModel(),
              update: (context, viewModel) => viewModel),
        ],
        child: Consumer<InsertAddressControllerViewModel?>(
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
                        'Inserisci il tuo indirizzo',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: AddressField(
                          viewModel: viewModel!,
                          node: _address,
                        )),
                    const SizedBox(
                      height: Dimension.paddingL,
                    ),
                    SvgPicture.asset(ImageSrc.userPositionArt,
                        semanticsLabel: 'Art Background'),
                    const Spacer(),
                    const SizedBox(height: Dimension.padding),
                    AnimatedCrossFade(
                      crossFadeState: isKeyboardVisible
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      secondChild: const SizedBox(),
                      firstChild: MainButton(
                        onPressed: () => viewModel.onSendClick(context),
                        text: 'Invia',
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
