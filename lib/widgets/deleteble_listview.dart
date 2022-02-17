import 'package:flutter/material.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/widgets/deletable_card.dart';

class DeletableListView<T> extends StatefulWidget {
  const DeletableListView({
    Key? key,
    required this.itemBuilder,
    required this.items,
    required this.idGetter,
    required this.onDelete,
    this.title,
    required this.alertDeleteText,
  }) : super(key: key);
  final Widget Function(T) itemBuilder;
  final List<T> items;
  final int Function(T) idGetter;
  final Function(T) onDelete;
  final String? title;
  final String alertDeleteText;

  @override
  State<DeletableListView> createState() => _DeletableListViewState<T>();
}

class _DeletableListViewState<T> extends State<DeletableListView<T>> {
  List<int> openedTiles = [];

  void handlingOpenChange(int id, bool status) {
    if (status) {
      //Open
      if (!openedTiles.contains(id)) {
        openedTiles.add(id);
      }
    } else {
      //Closed
      if (openedTiles.contains(id)) {
        openedTiles.remove(id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(left: Dimension.padding, top: Dimension.padding),
            child: Text(
              widget.title!,
            ),
          ),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            itemBuilder: (BuildContext context, int index) {
              return DeletableCard(
                maxWidth: MediaQuery.of(context).size.width / 3,
                id: widget.idGetter(widget.items[index]),
                onDelete: () {
                  SAAlertDialog.displayAlertWithButtons(context, "Attenzione", widget.alertDeleteText, [
                    MaterialButton(
                      onPressed: null,
                      child: Text(
                        'Annulla',
                        style: Theme.of(context).textTheme.dialogButtonRefuse,
                      ),
                    ),
                    MaterialButton(
                        onPressed: () {
                          handlingOpenChange(widget.idGetter(widget.items[index]), false);
                          widget.onDelete(widget.items[index]);
                        },
                        child: Text(
                          'OK',
                          style: Theme.of(context).textTheme.dialogButtonAccept,
                        )),
                  ]);
                },
                onOpenStateChange: (bool val) => handlingOpenChange(widget.idGetter(widget.items[index]), val),
                isOpened: openedTiles.contains(widget.idGetter(widget.items[index])),
                card: widget.itemBuilder(widget.items[index]),
              );
            })
      ],
    );
  }
}
