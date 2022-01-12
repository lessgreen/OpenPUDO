import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';

class MainButton extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  final Function() onPressed;

  const MainButton(
      {Key? key,
      required this.text,
      this.padding = const EdgeInsets.only(
          bottom: Dimension.paddingL,
          left: Dimension.padding,
          right: Dimension.padding),
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: TextButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text),
            ],
          ),
          onPressed: onPressed,
        ),
      );
}
