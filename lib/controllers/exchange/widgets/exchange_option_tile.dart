import 'package:flutter/material.dart';
import 'package:qui_green/models/exhange_option_model.dart';
import 'package:qui_green/resources/res.dart';

class ExchangeOptionTile extends StatelessWidget {
  final bool value;
  final Function(bool) onSelect;
  final bool isNonMultipleActive;
  final ExchangeOptionModel model;
  final Function(String) onTextChange;

  const ExchangeOptionTile(
      {Key? key,
      required this.value,
      required this.isNonMultipleActive,
      required this.onSelect,
      required this.model,
      required this.onTextChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: Dimension.paddingS,
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: '',
                  style: Theme.of(context).textTheme.subtitle1,
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        model.icon,
                        color: AppColors.cardColor,
                      ),
                    ),
                    const WidgetSpan(
                      child: SizedBox(
                        width: Dimension.padding,
                      ),
                    ),
                    TextSpan(
                      text: model.name,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          ?.copyWith(height: 1.5, letterSpacing: 0),
                    ),
                  ],
                ),
              ),
            ),
            Checkbox(
              activeColor: AppColors.primaryColorDark,
              value: value,
              shape: const CircleBorder(),
              onChanged: isNonMultipleActive
                  ? null
                  : (bool? val) => onSelect(val ?? false),
            ),
          ],
        ),
        AnimatedCrossFade(
            firstChild: Container(
              width: double.infinity,
            ),
            secondChild: Container(
              margin: const EdgeInsets.all(Dimension.paddingS),
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(Dimension.borderRadiusS)),
              child: TextFormField(
                onChanged: (newVal) => onTextChange(newVal),
                maxLines: 5,
                decoration: InputDecoration(
                    hintText: model.hintText,
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(fontStyle: FontStyle.italic),
                    border: InputBorder.none),
              ),
            ),
            crossFadeState: value && model.hasField
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 100)),
        const Divider(color: Colors.grey),
      ],
    );
  }
}
