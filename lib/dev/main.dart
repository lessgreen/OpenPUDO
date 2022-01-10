import 'package:flutter/material.dart';
import 'package:qui_green/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  mainCommon(
    isProd: false,
    host: "https://api-dev.quigreen.it",
  );
}
