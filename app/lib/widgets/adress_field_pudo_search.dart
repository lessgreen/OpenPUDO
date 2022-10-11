import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:qui_green/commons/extensions/additional_text_theme_styles.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/models/address_model.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/view_models/maps_controller_viewmodel.dart';
import 'package:qui_green/widgets/adress_overlay_pudo_search.dart';

class AdressFieldPudoSearch extends StatefulWidget {
  final MapsControllerViewModel viewModel;

  const AdressFieldPudoSearch({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<AdressFieldPudoSearch> createState() => _AdressFieldPudoSearchState();

  onAddressTap(AddressModel e) {
    viewModel.position = LatLng(e.lat!, e.lon!);
    viewModel.isOpenListAddress = false;
    viewModel.mapController?.move(LatLng(e.lat!, e.lon!), 8);
  }
}

class _AdressFieldPudoSearchState extends State<AdressFieldPudoSearch> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoTextField(
          placeholder: 'search'.localized(context, 'general'),
          padding: const EdgeInsets.all(Dimension.padding),
          prefix: const Padding(
            padding: EdgeInsets.only(left: Dimension.paddingS),
            child: Icon(
              CupertinoIcons.search,
              color: AppColors.colorGrey,
            ),
          ),
          placeholderStyle: Theme.of(context).textTheme.bodyTextSecondary,
          controller: widget.viewModel.addressController,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Dimension.borderRadiusSearch)),
          autofocus: false,
          textInputAction: TextInputAction.done,
          onChanged: (newValue) {
            widget.viewModel.onSearchChanged(newValue);
          },
        ),
        AdressOverlayPudoSearch(viewModel: widget.viewModel),
      ],
    );
  }
}
