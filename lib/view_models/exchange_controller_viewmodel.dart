
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:qui_green/models/exchange_option_state_model.dart';
import 'package:qui_green/models/exhange_option_model.dart';
import 'package:qui_green/resources/routes_enum.dart';

class ExchangeControllerViewModel extends ChangeNotifier {
  //Example: to use NetworkManager, use the getInstance: NetworkManager.instance...

  // ************ Navigation *****
  onSendClick(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.pudoTutorial);
  }

  //TODO implementation of network fetched options
  final List<ExchangeOptionModel> options = [
    ExchangeOptionModel(
        hasField: false,
        hintText: "",
        acceptMultiple: false,
        name:
            "Gratis per tutti, basta un sorriso. Lo facciamo insieme per l'ambiente!",
        icon: Icons.emoji_emotions),
    ExchangeOptionModel(
        hasField: false,
        acceptMultiple: true,
        hintText: "",
        name: "Gratis per i clienti abituali.",
        icon: Icons.emoji_emotions),
    ExchangeOptionModel(
        hasField: true,
        hintText:
            "Se vuoi specifica che tipo di tessera o abbonamento sono necessari.",
        acceptMultiple: true,
        name:
            "Gratis per associati, abbonati o possessori di tessera di fedeltà.",
        icon: Icons.credit_card_rounded),
    ExchangeOptionModel(
        hasField: false,
        hintText: "",
        acceptMultiple: true,
        name: "Acquisto di qualcosa o consumazione al momento del ritiro.",
        icon: Icons.shopping_bag_rounded),
    ExchangeOptionModel(
        hasField: false,
        hintText: "",
        acceptMultiple: true,
        name: "Pagamento del servizio per pacco ritirato.",
        icon: Icons.monetization_on_rounded),
  ];

  List<ExchangeOptionStateModel> optionValues = [
    ExchangeOptionStateModel(value: false, textValue: ""),
    ExchangeOptionStateModel(value: false, textValue: ""),
    ExchangeOptionStateModel(value: false, textValue: ""),
    ExchangeOptionStateModel(value: false, textValue: ""),
    ExchangeOptionStateModel(value: false, textValue: ""),
  ];

  void onValueChange(int index, bool value) {
    if (options[index].acceptMultiple) {
      optionValues[index] = optionValues[index].copyWith(value: value);
    } else {
      optionValues = optionValues.map((e) => e.copyWith(value: false)).toList();
      optionValues[index] = optionValues[index].copyWith(value: value);
    }
    notifyListeners();
  }

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

  void onTextChange(int index, String value) {
    optionValues[index] = optionValues[index].copyWith(textValue: value);
    notifyListeners();
  }
}
