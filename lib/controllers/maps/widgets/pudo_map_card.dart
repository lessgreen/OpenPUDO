import 'package:flutter/material.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/resources/res.dart';

class PudoMapCard extends StatelessWidget {
  final Function() onTap;
  final String image;
  final String name;
  final String address;
  final int stars;

  const PudoMapCard(
      {Key? key,
      required this.onTap,
      required this.image,
      required this.name,
      required this.address,
      required this.stars})
      : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimension.padding),
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
                child: CustomNetworkImage(
                  url: image,
                  width: 110,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: Dimension.padding,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
