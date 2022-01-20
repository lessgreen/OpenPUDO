import 'package:flutter/cupertino.dart';
import 'package:qui_green/controllers/maps/widgets/pudo_map_card.dart';

class PudoCardList extends StatelessWidget {
  final Function(int) onPageChange;
  final Function() onTap;

  const PudoCardList(
      {Key? key, required this.onPageChange, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: PageView.builder(
          onPageChanged: (index) => onPageChange(index),
          controller: PageController(viewportFraction: 1),
          itemCount: 2,
          itemBuilder: (context, index) =>
              PudoMapCard(
                name: "Bar - La pinta",
                address: "Via ippolito, 8",
                stars: 3,
                onTap: onTap,
                image:
                'https://cdn.skuola.net/news_foto/2017/descrizione-bar.jpg',
              )),
    );
  }
}
