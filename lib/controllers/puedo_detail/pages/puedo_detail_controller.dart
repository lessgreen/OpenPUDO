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
import 'package:qui_green/commons/widgets/text_field_button.dart';
import 'package:qui_green/controllers/insert_address/di/insert_address_controller_providers.dart';
import 'package:qui_green/controllers/insert_address/viewmodel/insert_address_controller_viewmodel.dart';
import 'package:qui_green/controllers/puedo_detail/di/puedo_detail_controller_providers.dart';
import 'package:qui_green/controllers/puedo_detail/viewmodel/puedo_detail_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';

class PuedoDetailController extends StatefulWidget {
  const PuedoDetailController({Key? key}) : super(key: key);

  @override
  _PuedoDetailControllerState createState() => _PuedoDetailControllerState();
}

class _PuedoDetailControllerState extends State<PuedoDetailController> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: puedoDetailControllerProviders,
        child: Consumer<PuedoDetailControllerViewModel?>(
            builder: (_, viewModel, __) {
          return WillPopScope(
            onWillPop: () async => true,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.white.withOpacity(0.8),
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                toolbarHeight: 0,
                leading: const SizedBox(),
              ),
              body: SafeArea(
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        color: Colors.white.withOpacity(0.8),
                        padding:
                            const EdgeInsets.only(bottom: Dimension.padding),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: Dimension.paddingS),
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: AppColors.primaryColorDark,
                                    ),
                                  ),
                                ),
                                Text(
                                  "Bar - La pinta",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      ?.copyWith(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextFieldButton(
                                    text: "Scegli",
                                    onPressed: () =>
                                        viewModel?.onSelectPress(context),
                                  ),
                                ),
                              ],
                            ),
                            Image.network(
                                'https://cdn.skuola.net/news_foto/2017/descrizione-bar.jpg'),
                            Padding(
                              padding: const EdgeInsets.all(Dimension.padding),
                              child: Row(
                                children: [
                                  Text(
                                    'Bar - La pinta',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.yellow.shade700,
                                      ),
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.yellow.shade700,
                                      ),
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.yellow.shade700,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: Dimension.padding,
                                  right: Dimension.padding),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: AppColors.primaryColorDark,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Via Ippolito 8 - 21100 Milano'),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: Dimension.padding,
                                  right: Dimension.padding),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: AppColors.primaryColorDark,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('351337651'),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: Dimension.padding,
                                  right: Dimension.padding),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    color: AppColors.primaryColorDark,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '123',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'persone hanno già scelto\nquest’attività come\npunto di ritiro QuiGreen.',
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: MediaQuery.of(context).size.width / 3 * 2,
                              height: 1,
                              color: AppColors.primaryColorDark,
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Spacer(),
                                Icon(
                                  Icons.info,
                                  color: AppColors.primaryColorDark,
                                ),
                                Text(
                                  'Per utilizzare QuiGreen in questo locale è richiesto:',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic),
                                ),
                                Spacer()
                              ],
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: MediaQuery.of(context).size.width / 3 * 2,
                              child: Text(
                                '“Vorrei essere pagato con una consumazione al tavolo.”',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }));
  }
}
