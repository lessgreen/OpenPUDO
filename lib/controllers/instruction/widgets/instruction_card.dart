import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';

class InstructionCard extends StatelessWidget {
  final String title;
  final String description;
  final int activeIndex;
  final int pages;
  final Widget bottomWidget;

  const InstructionCard(
      {Key? key,
      required this.title,
      required this.description,
      required this.activeIndex,
      required this.pages,
      required this.bottomWidget})
      : super(key: key);

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: Dimension.paddingXS),
      height: 8.0,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryColorDark : Colors.grey.shade300,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
          const SizedBox(
            height: Dimension.padding,
          ),
          Expanded(
            flex: 2,
            child: Container(
                padding: const EdgeInsets.only(
                    left: Dimension.padding, right: Dimension.padding),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                )),
          ),
          const SizedBox(
            height: Dimension.padding,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
                pages,
                (index) => index == activeIndex
                    ? _indicator(true)
                    : _indicator(false)),
          ),
          const SizedBox(
            height: Dimension.padding,
          ),
          //child
          Expanded(
            flex: 7,
            child: bottomWidget,
          ),
          const SizedBox(
            height: Dimension.paddingL,
          ),
        ],
      );
}
