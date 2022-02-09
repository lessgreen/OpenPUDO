import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:qui_green/models/address_model.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/view_models/maps_search_controller_viewmodel.dart';

class AdressOverlayPudoSearch extends StatefulWidget {
  final MapsSearchControllerViewModel viewModel;

  const AdressOverlayPudoSearch({Key? key, required this.viewModel})
      : super(key: key);

  @override
  _AdressOverlayPudoSearchState createState() =>
      _AdressOverlayPudoSearchState();

  onAddressTap(AddressModel e) {
    viewModel.position = LatLng(e.lat!, e.lon!);
    viewModel.isOpenListAddress = false;
    viewModel.mapController?.move(LatLng(e.lat!, e.lon!), 8);
  }
}

class _AdressOverlayPudoSearchState extends State<AdressOverlayPudoSearch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimension.paddingS),
      margin: EdgeInsets.only(top: Dimension.paddingXS),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(Dimension.borderRadiusSearch)),
      height: widget.viewModel.isOpenListAddress
          ? MediaQuery.of(context).size.height / 3
          : 0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: widget.viewModel.addresses.map((e) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.onAddressTap(e),
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
                      Text(e.label ?? ""),
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
