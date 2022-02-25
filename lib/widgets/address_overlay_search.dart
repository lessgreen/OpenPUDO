import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/resources/res.dart';

class AddressOverlaySearch extends StatefulWidget {
  final List<GeoMarker> addresses;
  final Function(GeoMarker) onTap;
  final BorderRadius? borderRadius;
  const AddressOverlaySearch({Key? key, required this.addresses,required this.onTap,this.borderRadius}) : super(key: key);

  @override
  _AddressOverlaySearchState createState() => _AddressOverlaySearchState();
}

class _AddressOverlaySearchState extends State<AddressOverlaySearch> {
  _buildPudo(GeoMarker e) => RichText(
    textAlign: TextAlign.justify,
    text: TextSpan(
      text: '',
      style: Theme.of(context).textTheme.bodyTextLight,
      children: [
        WidgetSpan(
          child: SvgPicture.asset(
            ImageSrc.fillBox,
            width: 18,
            height: 18,
            color: AppColors.primaryColorDark,
          ),
        ),
        const WidgetSpan(
          child: SizedBox(
            width: Dimension.paddingXS,
          ),
        ),
        TextSpan(
          text: e.pudo?.businessName ?? "",
        ),
      ],
    ),
  );

  _buildAddress(GeoMarker e) => RichText(
    textAlign: TextAlign.justify,
    text: TextSpan(
      text: '',
      style: Theme.of(context).textTheme.bodyTextLight,
      children: [
        TextSpan(
          text: e.address?.label ?? "",
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimension.paddingS),
      margin: const EdgeInsets.only(top: Dimension.paddingXS),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: widget.borderRadius??BorderRadius.circular(Dimension.borderRadiusSearch)),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: widget.addresses.map((e) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.onTap(e),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: Dimension.paddingS,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: Dimension.paddingXS,
                      ),
                      if (e.pudo != null) _buildPudo(e),
                      if (e.pudo == null) _buildAddress(e),
                      const SizedBox(
                        height: Dimension.paddingXS,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: Dimension.paddingS,
                  ),
                  Divider(color: Colors.grey.shade400, height: 1),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}