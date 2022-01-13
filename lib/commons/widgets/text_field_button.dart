import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';

class TextFieldButton extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  final Function() onPressed;

  const TextFieldButton(
      {Key? key,
      required this.text,
      this.padding = EdgeInsets.zero,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) => TextButton(
        
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              ?.copyWith(color: AppColors.primaryColorDark),
        ),
        style: Theme.of(context).textButtonTheme.style?.copyWith(
            padding: MaterialStateProperty.all(padding),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shape: MaterialStateProperty.all(
                const RoundedRectangleBorder(side: BorderSide.none))),
        onPressed: onPressed,
      );
}
