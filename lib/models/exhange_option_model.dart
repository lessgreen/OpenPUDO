import 'package:flutter/material.dart';

class ExchangeOptionModel {
  final bool hasField;
  final bool acceptMultiple;
  final String name;
  final IconData icon;
  final String hintText;

  ExchangeOptionModel(
      {required this.hasField,
      required this.acceptMultiple,
      required this.name,
      required this.icon,
      required this.hintText});
}
