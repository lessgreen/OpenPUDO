import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';

class ListViewHeader extends StatelessWidget {
  final int itemCount;
  final bool shrinkWrap;
  final Function(BuildContext, int) contentBuilder;
  final ScrollPhysics? physics;
  final String title;
  final TextStyle? titleStyle;
  final EdgeInsets itemPadding;
  final ScrollController? scrollController;
  final int actualItemCount;
  final bool hasScrollbar;

  const ListViewHeader({
    Key? key,
    required this.itemCount,
    required this.contentBuilder,
    required this.title,
    this.hasScrollbar = false,
    this.physics,
    this.titleStyle,
    this.scrollController,
    this.shrinkWrap = false,
    this.itemPadding = EdgeInsets.zero,
  })  : actualItemCount = itemCount + 1,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var _listView = ListView.builder(
      itemCount: actualItemCount,
      physics: physics,
      shrinkWrap: shrinkWrap,
      controller: scrollController,
      itemBuilder: (context, index) {
        if (index == 0) {
          //Start
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimension.padding, vertical: Dimension.padding),
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: titleStyle ?? TextStyle(color: Colors.grey.shade800),
            ),
          );
        } else {
          //Actual item
          return Padding(
            padding: itemPadding,
            child: contentBuilder(context, index - 1),
          );
        }
      },
    );
    return hasScrollbar
        ? CupertinoScrollbar(
            controller: scrollController,
            child: _listView,
          )
        : _listView;
  }
}
