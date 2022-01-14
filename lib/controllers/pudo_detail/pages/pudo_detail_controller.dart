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
import 'package:qui_green/commons/widgets/text_field_button.dart';
import 'package:qui_green/controllers/pudo_detail/di/pudo_detail_controller_providers.dart';
import 'package:qui_green/controllers/pudo_detail/viewmodel/pudo_detail_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';

class PudoDetailController extends StatefulWidget {
  const PudoDetailController({Key? key}) : super(key: key);

  @override
  _PudoDetailControllerState createState() => _PudoDetailControllerState();
}

class _PudoDetailControllerState extends State<PudoDetailController> {
  Widget _buildPudoDetail() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: Dimension.padding),
          Row(
            children: [
              const Text(
                'Bar - La pinta',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                width: Dimension.paddingS,
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
          const SizedBox(height: Dimension.paddingS),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              text: '',
              style: Theme.of(context).textTheme.bodyText2,
              children: const [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryColorDark,
                  ),
                ),
                WidgetSpan(
                  child: SizedBox(
                    width: Dimension.paddingS,
                  ),
                ),
                TextSpan(text: "Via Ippolito 8 - 21100 Milano"),
              ],
            ),
          ),
          const SizedBox(height: Dimension.paddingS),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              text: '',
              style: Theme.of(context).textTheme.bodyText2,
              children: const [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.phone,
                    color: AppColors.primaryColorDark,
                  ),
                ),
                WidgetSpan(
                  child: SizedBox(
                    width: Dimension.paddingS,
                  ),
                ),
                TextSpan(text: "+39-02-123-4567"),
              ],
            ),
          ),
          const SizedBox(height: Dimension.paddingS),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              text: '',
              style: Theme.of(context).textTheme.bodyText2,
              children: const [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.people,
                    color: AppColors.primaryColorDark,
                  ),
                ),
                WidgetSpan(
                  child: SizedBox(
                    width: Dimension.paddingS,
                  ),
                ),
                TextSpan(
                    text: '123', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        ' persone hanno già scelto quest’attività come punto di ritiro QuiGreen.'),
              ],
            ),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: pudoDetailControllerProviders,
        child: Consumer<PudoDetailControllerViewModel?>(
            builder: (_, viewModel, __) {
          return WillPopScope(
            onWillPop: () async => true,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: Colors.white,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                title: Text(
                  "Bar - La pinta",
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                leading: GestureDetector(
                  onTap: () => viewModel?.goBack(context),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AppColors.primaryColorDark,
                  ),
                ),
                actions: [
                  TextFieldButton(
                    text: "Scegli",
                    onPressed: () => viewModel?.onSelectPress(context),
                  )
                ],
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: Colors.white.withOpacity(0.8),
                    padding: const EdgeInsets.only(bottom: Dimension.padding),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Image.network(
                            'https://cdn.skuola.net/news_foto/2017/descrizione-bar.jpg'),
                        _buildPudoDetail(),
                        const SizedBox(height: Dimension.padding),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 1,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: Dimension.padding),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.info,
                              color: AppColors.primaryColorDark,
                            ),
                            const SizedBox(
                              width: Dimension.paddingS,
                            ),
                            Text(
                              'Per utilizzare QuiGreen in questo locale è richiesto:',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3 * 2,
                          child: Text(
                            '“Vorrei essere pagato con una consumazione al tavolo.”',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                ?.copyWith(
                                    height: 2,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w300),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }
}
