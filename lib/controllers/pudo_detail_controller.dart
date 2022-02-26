/*
 OpenPUDO - PUDO and Micro-delivery software for Last Mile Collaboration
 Copyright (C) 2020-2022 LESS SRL - https://less.green

 This file is part of OpenPUDO software.

 OpenPUDO is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License version 3
 as published by the Copyright Owner.

 OpenPUDO is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License version 3 for more details.

 You should have received a copy of the GNU Affero General Public License
 version 3 published by the Copyright Owner along with OpenPUDO.  
 If not, see <https://github.com/lessgreen/OpenPUDO>.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/commons/ui/optimized_cupertino_navigation_bar.dart';
import 'package:qui_green/commons/utilities/url_launcher_helper.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/widgets/text_field_button.dart';

class PudoDetailController extends StatefulWidget {
  const PudoDetailController({Key? key, required this.dataModel, required this.checkIsAlreadyAdded, this.nextRoute, required this.useCupertinoScaffold}) : super(key: key);
  final PudoProfile dataModel;
  final bool checkIsAlreadyAdded;
  final String? nextRoute;
  final bool useCupertinoScaffold;

  @override
  _PudoDetailControllerState createState() => _PudoDetailControllerState();
}

class _PudoDetailControllerState extends State<PudoDetailController> with ConnectionAware {
  bool checkComplete = false;

  @override
  void initState() {
    super.initState();
    if (widget.checkIsAlreadyAdded) {
      getIfPudoAlreadySelected();
    } else {
      nextVisible = true;
      checkComplete = true;
    }
  }

  void openModal() {
    SAAlertDialog.displayModalWithButtons(context, "Scegli un'azione", [
      CupertinoActionSheetAction(
        child: const Text('Chiama al telefono'),
        onPressed: () {
          UrlLauncherHelper.launchUrl(UrlTypes.tel, widget.dataModel.publicPhoneNumber!);
        },
      ),
      CupertinoActionSheetAction(
        child: const Text('Invia un messaggio'),
        onPressed: () {
          UrlLauncherHelper.launchUrl(UrlTypes.sms, widget.dataModel.publicPhoneNumber!);
        },
      ),
      CupertinoActionSheetAction(
        child: const Text('Invia un WhatsApp'),
        onPressed: () {
          UrlLauncherHelper.launchUrl(UrlTypes.whatsapp, widget.dataModel.publicPhoneNumber!);
        },
      )
    ]);
  }

  Widget _buildPudoDetail() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: Dimension.padding),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(style: Theme.of(context).textTheme.headline6, children: [
              TextSpan(text: widget.dataModel.businessName),
              WidgetSpan(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                    5,
                    (index) => Icon(
                      Icons.star_rounded,
                      color: (index + 1 <= (widget.dataModel.rating?.stars ?? 0)) ? Colors.yellow.shade700 : Colors.grey.shade200,
                    ),
                  ),
                ),
              ),
            ]),
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
                TextSpan(text: widget.dataModel.address!.label ?? ""),
              ],
            ),
          ),
          if (widget.dataModel.publicPhoneNumber != null) const SizedBox(height: Dimension.paddingS),
          if (widget.dataModel.publicPhoneNumber != null)
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                text: '',
                style: Theme.of(context).textTheme.bodyText2,
                children: [
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: SvgPicture.asset(
                        ImageSrc.phoneIconFill,
                        color: AppColors.primaryColorDark,
                        width: 23,
                        height: 23,
                      )),
                  const WidgetSpan(
                    child: SizedBox(
                      width: Dimension.paddingS,
                    ),
                  ),
                  TextSpan(text: widget.dataModel.publicPhoneNumber ?? ""),
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
                  text: (widget.dataModel.customerCount ?? 0).toString(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const TextSpan(text: ' persone hanno già scelto quest’attività come punto di ritiro QuiGreen.'),
              ],
            ),
          ),
        ]),
      );

  Widget _buildPageWithCupertinoScaffold() => CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: OptimizedCupertinoNavigationBar.build(context,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          middle: AnimatedCrossFade(
              firstChild: const SizedBox(
                height: 30,
                width: double.infinity,
              ),
              secondChild: Text(
                widget.dataModel.businessName,
                style: Theme.of(context).textTheme.navBarTitle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              crossFadeState: checkComplete ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 100)),
          trailing: AnimatedCrossFade(
              firstChild: const SizedBox(
                height: 26,
              ),
              secondChild: nextVisible
                  ? TextFieldButton(
                      onPressed: handleSelect,
                      text: 'Scegli',
                      textColor: Colors.white,
                    )
                  : widget.dataModel.publicPhoneNumber != null
                      ? IconButton(
                          onPressed: () => openModal(),
                          icon: SvgPicture.asset(
                            ImageSrc.phoneIcon,
                            color: Colors.white,
                            width: 26,
                            height: 26,
                          ),
                        )
                      : const SizedBox(),
              crossFadeState: checkComplete ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 100))),
      child: _buildBody());

  Widget _buildPageWithBaseScaffold() => Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: ThemeData.light().scaffoldBackgroundColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: AnimatedCrossFade(
            firstChild: const SizedBox(
              height: 30,
              width: double.infinity,
            ),
            secondChild: Text(
              widget.dataModel.businessName,
              style: Theme.of(context).textTheme.navBarTitleDark,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            crossFadeState: checkComplete ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 100)),
        centerTitle: true,
        leading: CupertinoNavigationBarBackButton(
          color: AppColors.primaryColorDark,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          AnimatedCrossFade(
              firstChild: const SizedBox(
                height: 30,
              ),
              secondChild: nextVisible
                  ? TextFieldButton(
                      onPressed: handleSelect,
                      text: 'Scegli',
                      textColor: AppColors.primaryColorDark,
                    )
                  : widget.dataModel.publicPhoneNumber != null
                      ? IconButton(
                          onPressed: () => openModal(),
                          icon: SvgPicture.asset(
                            ImageSrc.phoneIcon,
                            color: AppColors.primaryColorDark,
                            width: 26,
                            height: 26,
                          ),
                        )
                      : const SizedBox(),
              crossFadeState: checkComplete ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 100))
        ],
      ),
      body: _buildBody());

  Widget _buildBody() => ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: Dimension.padding),
            alignment: Alignment.center,
            child: Column(
              children: [
                AspectRatio(
                    aspectRatio: 18 / 9,
                    child: CustomNetworkImage(
                      url: widget.dataModel.pudoPicId,
                      fit: BoxFit.cover,
                    )),
                _buildPudoDetail(),
                const SizedBox(height: Dimension.padding),
                Container(
                  width: MediaQuery.of(context).size.width / 3 * 2,
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
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3 * 2,
                  child: Text(
                    '“${widget.dataModel.rewardMessage ?? ""}”',
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          height: 2,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return widget.useCupertinoScaffold ? _buildPageWithCupertinoScaffold() : _buildPageWithBaseScaffold();
  }

  bool nextVisible = false;

  void getIfPudoAlreadySelected() {
    NetworkManager.instance.getMyPudos().then((value) {
      final index = value.indexWhere((element) => element.pudoId == widget.dataModel.pudoId);
      if (index > -1) {
        setState(() {
          checkComplete = true;
          nextVisible = false;
        });
      } else {
        setState(() {
          checkComplete = true;
          nextVisible = true;
        });
      }
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  void handleSelect() {
    switch (widget.nextRoute) {
      case Routes.personalData:
        goToPersonalData();
        break;
      case Routes.registrationComplete:
        goToRegistration();
        break;
      default:
        selectPudo();
        break;
    }
  }

  void goToRegistration() {
    NetworkManager.instance
        .addPudoFavorite(widget.dataModel.pudoId.toString())
        .then((value) => Navigator.of(context).pushNamed(
              Routes.registrationComplete,
              arguments: widget.dataModel,
            ))
        .catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  void selectPudo() {
    NetworkManager.instance.addPudoFavorite(widget.dataModel.pudoId.toString()).then((value) {
      Provider.of<CurrentUser>(context, listen: false).triggerReload();
      Navigator.of(context).pop();
    }).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, "Error", onError));
  }

  void goToPersonalData() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.personalData,
      ModalRoute.withName('/'),
      arguments: widget.dataModel,
    );
  }
}
