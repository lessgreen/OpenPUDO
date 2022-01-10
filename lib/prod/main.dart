import 'package:flutter/material.dart';
import 'package:qui_green/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  mainCommon(
    isProd: true,
    host: "https://api.quigreen.it",
  );
}
