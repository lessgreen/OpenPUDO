import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';

class ListViewHeader extends StatelessWidget {
  const ListViewHeader({
    Key? key,
    required this.itemCount,
    this.shrinkWrap = false,
    required this.itemBuilder,
    this.physics,
    this.itemPadding = EdgeInsets.zero,
    required this.title,
    this.scrollController,
    required this.endText,
  }) : super(key: key);

  final int itemCount;
  final bool shrinkWrap;
  final Function(BuildContext, int) itemBuilder;
  final ScrollPhysics? physics;
  final String title;
  final EdgeInsets itemPadding;
  final ScrollController? scrollController;
  final String endText;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemBuilder: (context, index) {
        if (index == 0) {
          //Start
          return Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimension.padding, vertical: Dimension.padding),
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(color: Colors.grey.shade800),
              ));
        } else if (index == (itemCount + 2) - 1) {
          //No more items
          return Container(
              alignment: Alignment.center,
              child: Text(
                endText,
                style: TextStyle(color: Colors.grey.shade800),
              ));
        } else {
          //Actual item
          return Padding(
            padding: itemPadding,
            child: itemBuilder(context, index - 1),
          );
        }
      },
      itemCount: itemCount + 2,
      physics: physics,
      shrinkWrap: shrinkWrap,
    );
  }
}
