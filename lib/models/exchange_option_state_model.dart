
class ExchangeOptionStateModel {
  final bool value;
  final String textValue;

  ExchangeOptionStateModel({
    required this.value,
    required this.textValue,
  });

  ExchangeOptionStateModel copyWith({value, textValue}) =>
      ExchangeOptionStateModel(
        value: value ?? this.value,
        textValue: textValue ?? this.textValue,
      );
}
