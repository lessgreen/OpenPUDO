import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';

class MainButton extends StatelessWidget {
  final bool enabled;
  final String text;
  final EdgeInsets padding;
  final Function() onPressed;

  const MainButton({
    Key? key,
    required this.text,
    this.enabled = true,
    this.padding = const EdgeInsets.only(bottom: Dimension.paddingL, left: Dimension.padding, right: Dimension.padding),
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: TextButton(
          style: enabled
              ? null
              : Theme.of(context).textButtonTheme.style?.copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      AppColors.primarySwatch.withAlpha(100),
                    ),
                  ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text),
            ],
          ),
          onPressed: enabled ? onPressed : null,
        ),
      );
}
