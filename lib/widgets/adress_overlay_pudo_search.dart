import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/view_models/maps_controller_viewmodel.dart';

class AdressOverlayPudoSearch extends StatefulWidget {
  final MapsControllerViewModel viewModel;

  const AdressOverlayPudoSearch({Key? key, required this.viewModel}) : super(key: key);

  @override
  _AdressOverlayPudoSearchState createState() => _AdressOverlayPudoSearchState();
}

class _AdressOverlayPudoSearchState extends State<AdressOverlayPudoSearch> {
  void onAddressTap(GeoMarker e) {
    if (e.pudo != null) {
      widget.viewModel.onPudoClick(context, e, false);
    } else {
      widget.viewModel.isOpenListAddress = false;
      widget.viewModel.animateMapTo(widget.viewModel, LatLng(e.lat!, e.lon!));
    }
  }

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
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(Dimension.borderRadiusSearch)),
      height: widget.viewModel.isOpenListAddress ? MediaQuery.of(context).size.height / 3 : 0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: widget.viewModel.addresses.map(
          (e) {
            return Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () => onAddressTap(e),
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
          },
        ).toList(),
      ),
    );
  }
}
