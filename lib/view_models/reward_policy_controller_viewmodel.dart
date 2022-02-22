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

import 'package:flutter/material.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/models/exchange_option_state_model.dart';
import 'package:qui_green/models/exhange_option_model.dart';
import 'package:qui_green/models/extra_info.dart';
import 'package:qui_green/models/reward_option.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class RewardPolicyControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  RewardPolicyControllerViewModel(BuildContext context) {
    NetworkManager.instance.getPudoRewardSchema().then((value) {
      if (value is List<RewardOption>) {
        dataSource = value;
      } else {
        SAAlertDialog.displayAlertWithClose(context, "Attention", "Qualcosa è andato storto");
      }
    }).catchError((error) => SAAlertDialog.displayAlertWithClose(context, "Attention", error));
  }

  // ************ Navigation *****
  onSendClick(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.pudoTutorial);
  }

  //TODO implementation of network fetched options

  List<RewardOption> _dataSource = [
    /*RewardOption(
      name: "free",
      text: "Gratis per tutti, basta un sorriso. Lo facciamo insieme per l'ambiente!",
      icon: IconInfoType.smile,
      exclusive: true,
      checked: false,
    ),
    RewardOption(
      name: "free",
      text: "Gratis una frase",
      icon: IconInfoType.smile,
      exclusive: false,
      checked: false,
      extraInfo: ExtraInfo(
        name: "free text",
        text: "scrivi del testo libero",
        type: ExtraInfoType.text,
        mandatoryValue: false,
        value: "pluto pippo paperino",
      ),
    ),
    RewardOption(
      name: "free",
      text: "Gratis per i clienti abituali.",
      icon: IconInfoType.shopping,
      exclusive: false,
      checked: false,
      extraInfo: ExtraInfo(
        name: "customer.select",
        text: "Specifica che tipo di utenti",
        type: ExtraInfoType.select,
        mandatoryValue: true,
        values: [
          ExtraInfoSelectItem(
            name: "1/day",
            text: "Un acquisto al giorno",
          ),
          ExtraInfoSelectItem(
            name: "1/week",
            text: "Un acquisto la settimana",
          ),
          ExtraInfoSelectItem(
            name: "1/month",
            text: "Un acquisto al mese",
          ),
          ExtraInfoSelectItem(
            name: "Other",
            text: "Altro",
            extraInfo: ExtraInfo(
              name: "testo",
              text: "per favore specifica altro",
              type: ExtraInfoType.text,
              mandatoryValue: true,
            ),
          ),
        ],
      ),
    ),
    RewardOption(
      name: "free",
      text: "Gratis una somma",
      icon: IconInfoType.money,
      exclusive: false,
      checked: false,
      extraInfo: ExtraInfo(
        name: "free text",
        text: "inserisci la somma",
        type: ExtraInfoType.decimal,
        mandatoryValue: false,
        min: 1.0,
        max: 10.0,
        step: 0.5,
        scale: 2.0,
      ),
    ),*/
  ];

  List<RewardOption> get dataSource => _dataSource;

  set dataSource(List<RewardOption> newVal){
    _dataSource = newVal;
    notifyListeners();
  }

  bool get mandatoryFulfilled {
    for (var aRow in dataSource) {
      if ((aRow.checked??false) && aRow.extraInfo != null && aRow.extraInfo!.mandatoryValue == true) {
        switch (aRow.extraInfo!.type) {
          case ExtraInfoType.text:
            if (aRow.extraInfo!.value == null) {
              return false;
            }
            break;
          case ExtraInfoType.decimal:
            if (aRow.extraInfo!.value == null) {
              return false;
            }
            break;
          case ExtraInfoType.select:
            if (aRow.extraInfo!.values == null) {
              return true;
            } else {
              for (var anOption in aRow.extraInfo!.values!) {
                if (anOption.checked == true) {
                  return true;
                }
              }
              return false;
            }
        }
      }
    }
    return true;
  }

  bool get isExclusiveSelected {
    for (var aRow in dataSource) {
      if ((aRow.exclusive??false) && (aRow.checked??false)) {
        return true;
      }
    }
    return false;
  }

  void onValueChange(int index, bool value) {
    if (isExclusiveSelected) {
      if (dataSource[index].exclusive == false) {
        return;
      }
    }
    dataSource[index].checked = value;
    notifyListeners();
  }

  void onSubSelectValueChange(int rowIndex, int optionIndex, bool value) {
    dataSource[rowIndex].extraInfo?.values?[optionIndex].checked = value;
    notifyListeners();
  }

  void onTextChange(int index, String value) {
    RewardOption? aRow = (index < dataSource.length) ? dataSource[index] : null;
    if (aRow == null || aRow.extraInfo == null) {
      return;
    }
    if (aRow.extraInfo!.type == ExtraInfoType.text || aRow.extraInfo!.type == ExtraInfoType.decimal) {
      aRow.extraInfo!.value = value;
      notifyListeners();
    }
  }

  void onSubTextChange(int rowIndex, int optionIndex, String value) {
    RewardOption? aRow = (rowIndex < dataSource.length) ? dataSource[rowIndex] : null;
    if (aRow == null || aRow.extraInfo == null) {
      return;
    }

    if (aRow.extraInfo == null || aRow.extraInfo!.values == null || optionIndex >= aRow.extraInfo!.values!.length) {
      return;
    }
    ExtraInfoSelectItem? subItem = aRow.extraInfo?.values?[optionIndex];
    if (subItem == null) {
      return;
    }
    if (subItem.extraInfo!.type == ExtraInfoType.text || subItem.extraInfo!.type == ExtraInfoType.decimal) {
      subItem.extraInfo!.value = value;
      notifyListeners();
    }
  }

  final List<ExchangeOptionModel> options = [
    ExchangeOptionModel(hasField: false, hintText: "", acceptMultiple: false, name: "Gratis per tutti, basta un sorriso. Lo facciamo insieme per l'ambiente!", icon: Icons.emoji_emotions),
    ExchangeOptionModel(hasField: false, acceptMultiple: true, hintText: "", name: "Gratis per i clienti abituali.", icon: Icons.emoji_emotions),
    ExchangeOptionModel(
        hasField: true,
        hintText: "Se vuoi specifica che tipo di tessera o abbonamento sono necessari.",
        acceptMultiple: true,
        name: "Gratis per associati, abbonati o possessori di tessera di fedeltà.",
        icon: Icons.credit_card_rounded),
    ExchangeOptionModel(hasField: false, hintText: "", acceptMultiple: true, name: "Acquisto di qualcosa o consumazione al momento del ritiro.", icon: Icons.shopping_bag_rounded),
    ExchangeOptionModel(hasField: false, hintText: "", acceptMultiple: true, name: "Pagamento del servizio per pacco ritirato.", icon: Icons.monetization_on_rounded),
  ];

  List<ExchangeOptionStateModel> optionValues = [
    ExchangeOptionStateModel(value: false, textValue: ""),
    ExchangeOptionStateModel(value: false, textValue: ""),
    ExchangeOptionStateModel(value: false, textValue: ""),
    ExchangeOptionStateModel(value: false, textValue: ""),
    ExchangeOptionStateModel(value: false, textValue: ""),
  ];

  bool isANonMultipleActive(index) {
    if (!options[index].acceptMultiple && optionValues[index].value) {
      return false;
    }
    for (int i = 0; i < optionValues.length; i++) {
      if (optionValues[i].value && !options[i].acceptMultiple) {
        return true;
      }
    }
    return false;
  }
}
