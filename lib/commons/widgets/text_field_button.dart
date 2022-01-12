import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';

class TextFieldButton extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  final Function() onPressed;

  const TextFieldButton(
      {Key? key,
      required this.text,
      this.padding = const EdgeInsets.only(
          bottom: Dimension.paddingL,
          left: Dimension.padding,
          right: Dimension.padding),
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
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shape: MaterialStateProperty.all(
                const RoundedRectangleBorder(side: BorderSide.none))),
        onPressed: onPressed,
      );
}
