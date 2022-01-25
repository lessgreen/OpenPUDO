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
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/commons/widgets/text_field_button.dart';
import 'package:qui_green/controllers/pudo_detail/models/pudo_detail_controller_data_model.dart';
import 'package:qui_green/controllers/pudo_detail/viewmodel/pudo_detail_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';

class PudoDetailController extends StatefulWidget {
  const PudoDetailController({Key? key, required this.dataModel})
      : super(key: key);
  final PudoDetailControllerDataModel dataModel;

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
              Text(
                widget.dataModel.pudoProfile.businessName,
                style: const TextStyle(fontSize: 18),
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
              children: [
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryColorDark,
                  ),
                ),
                const WidgetSpan(
                  child: SizedBox(
                    width: Dimension.paddingS,
                  ),
                ),
                TextSpan(
                    text: widget.dataModel.pudoProfile.address!.label ?? ""),
              ],
            ),
          ),
          if (widget.dataModel.pudoProfile.publicPhoneNumber != null)
            const SizedBox(height: Dimension.paddingS),
          if (widget.dataModel.pudoProfile.publicPhoneNumber != null)
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                text: '',
                style: Theme.of(context).textTheme.bodyText2,
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.phone,
                      color: AppColors.primaryColorDark,
                    ),
                  ),
                  const WidgetSpan(
                    child: SizedBox(
                      width: Dimension.paddingS,
                    ),
                  ),
                  TextSpan(
                      text:
                          widget.dataModel.pudoProfile.publicPhoneNumber ?? ""),
                ],
              ),
            ),
          const SizedBox(height: Dimension.paddingS),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              text: '',
              style: Theme.of(context).textTheme.bodyText2,
              children: [
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.people,
                    color: AppColors.primaryColorDark,
                  ),
                ),
                const WidgetSpan(
                  child: SizedBox(
                    width: Dimension.paddingS,
                  ),
                ),
                TextSpan(
                    text: (widget.dataModel.pudoProfile.customerCount ?? 0)
                        .toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(
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
        providers: [
          ChangeNotifierProxyProvider0<PudoDetailControllerViewModel?>(
              create: (context) => PudoDetailControllerViewModel(),
              update: (context, viewModel) => viewModel),
        ],
        child: Consumer<PudoDetailControllerViewModel?>(
            builder: (_, viewModel, __) {
          return WillPopScope(
            onWillPop: () async => true,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: ThemeData.light().scaffoldBackgroundColor,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                title: Text(
                  widget.dataModel.pudoProfile.businessName,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                leading: GestureDetector(
                  onTap: () => viewModel?.goBack(
                      context, widget.dataModel.initialPosition),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AppColors.primaryColorDark,
                  ),
                ),
                actions: [
                  TextFieldButton(
                    text: "Scegli",
                    onPressed: () => viewModel?.onSelectPress(context,
                        widget.dataModel.pudoProfile),
                  )
                ],
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: Dimension.padding),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        CustomNetworkImage(url: widget.dataModel.pudoProfile.pudoPicId),
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
                            '“${widget.dataModel.pudoProfile.rewardMessage ?? ""}”',
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
