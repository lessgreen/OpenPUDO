import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/widgets/deletable_card.dart';

class DeletableListView<T> extends StatefulWidget {
  final Widget Function(T) itemBuilder;
  final List<T> items;
  final int Function(T) idGetter;
  final Function(T) onDelete;
  final String? title;
  final String alertDeleteText;
  final bool hasScrollBar;
  final TextStyle? titleStyle;
  final bool showAlertOnDelete;
  final double rowHeight;
  final double horizontalPadding;
  final BorderRadius borderRadius;
  final EdgeInsets? itemPadding;
  final ScrollController? controller;

  const DeletableListView(
      {Key? key,
      this.controller,
      required this.itemBuilder,
      required this.items,
      required this.idGetter,
      required this.onDelete,
      required this.alertDeleteText,
      this.title,
      this.titleStyle,
      this.hasScrollBar = false,
      this.showAlertOnDelete = true,
      this.rowHeight = 100,
      this.horizontalPadding = Dimension.padding,
      required this.borderRadius,
      this.itemPadding})
      : super(key: key);

  @override
  State<DeletableListView> createState() => _DeletableListViewState<T>();
}

class _DeletableListViewState<T> extends State<DeletableListView<T>> {
  int? openedTile;
  List<GlobalKey<DeletableCardState>> tilesState = [];

  @override
  void initState() {
    super.initState();
    tilesState = List.generate(widget.items.length, (index) => GlobalKey<DeletableCardState>());
  }

  void handlingOpenChange() {
    for (GlobalKey<DeletableCardState> element in tilesState) {
      element.currentState?.closeCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.length != tilesState.length) {
      tilesState = List.generate(widget.items.length, (index) => GlobalKey<DeletableCardState>());
    }
    var _listView = ListView(
      controller: widget.controller,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(left: Dimension.padding, top: Dimension.padding),
            child: Text(
              widget.title!,
              style: widget.titleStyle,
            ),
          ),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            itemBuilder: (BuildContext context, int index) {
              return DeletableCard(
                itemPadding: widget.itemPadding ?? const EdgeInsets.symmetric(vertical: Dimension.paddingS),
                borderRadius: widget.borderRadius,
                horizontalPadding: widget.horizontalPadding,
                rowHeight: widget.rowHeight,
                key: tilesState[index],
                maxWidth: MediaQuery.of(context).size.width / 3,
                id: widget.idGetter(widget.items[index]),
                onDelete: () {
                  if (widget.showAlertOnDelete) {
                    SAAlertDialog.displayAlertWithButtons(context, 'warningTitle'.localized(context, 'general'), widget.alertDeleteText, [
                      MaterialButton(
                        onPressed: null,
                        child: Text(
                          'cancelButtonTitle'.localized(context, 'general'),
                          style: Theme.of(context).textTheme.dialogButtonRefuse,
                        ),
                      ),
                      MaterialButton(
                          onPressed: () {
                            handlingOpenChange();
                            widget.onDelete(widget.items[index]);
                          },
                          child: Text(
                            'Ok',
                            style: Theme.of(context).textTheme.dialogButtonAccept,
                          )),
                    ]);
                  } else {
                    handlingOpenChange();
                    widget.onDelete(widget.items[index]);
                  }
                },
                onOpenStateChange: () => handlingOpenChange(),
                openedId: openedTile,
                card: widget.itemBuilder(widget.items[index]),
              );
            })
      ],
    );
    return widget.hasScrollBar ? CupertinoScrollbar(child: _listView) : _listView;
  }
}
