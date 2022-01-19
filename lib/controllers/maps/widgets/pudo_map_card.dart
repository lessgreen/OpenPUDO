import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';

class PudoMapCard extends StatelessWidget {
  final Function() onTap;
  final String image;
  final String name;
  final String address;
  final int stars;
  final bool showOnly;

  const PudoMapCard(
      {Key? key,
      required this.onTap,
      required this.image,
      required this.name,
      required this.address,
      required this.stars,
      this.showOnly = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.all(Radius.circular(Dimension.borderRadiusS)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(Dimension.borderRadiusS),
                    bottomLeft: Radius.circular(Dimension.borderRadiusS)),
                child: Image.network(
                  image,
                  width: 110,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: Dimension.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: Dimension.paddingXS),
                    Text(
                      address,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Row(
                      children: List<Widget>.generate(
                          stars > 5 ? 5 : stars,
                          (index) => Icon(
                                Icons.star_rounded,
                                color: Colors.yellow.shade700,
                              )),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const Spacer(),
              if (!showOnly)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: Dimension.padding * 2.5,
                      bottom: Dimension.padding,
                    ),
                    child: Image.asset(
                      'assets/hand.png',
                      height: Dimension.chipIcon * 2,
                    ),
                  ),
                )
            ],
          ),
        ),
      );
}
