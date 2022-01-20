import 'package:flutter/material.dart';
import 'package:qui_green/controllers/insert_address/viewmodel/insert_address_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';

class AddressOverlay extends StatefulWidget {
  final InsertAddressControllerViewModel viewModel;
  final double positionTop;
  final double positionLeft;
  final double width;
  final Function(String?) onSelect;
  final Function() removeOverlay;

  const AddressOverlay({Key? key,
    required this.viewModel,
    required this.positionTop,
    required this.positionLeft,
    required this.width,
    required this.removeOverlay,
    required this.onSelect})
      : super(key: key);

  @override
  State<AddressOverlay> createState() => _AddressOverlayState();
}

class _AddressOverlayState extends State<AddressOverlay> {
  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.addresses.isEmpty) {
      widget.removeOverlay();
    }
    return Positioned(
        left: widget.positionLeft,
        top: widget.positionTop,
        child: Material(
            elevation: 0,
            color: Colors.white.withOpacity(0.9),
            child: Container(
                alignment: Alignment.bottomRight,
                width: widget.width,
                height: (MediaQuery
                    .of(context)
                    .size
                    .height / 3),
                child: Padding(
                  padding: const EdgeInsets.all(Dimension.paddingS),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: widget.viewModel.addresses.map((e) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  onTap: () => widget.onSelect(e.label),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      const SizedBox(
                                        height: Dimension.paddingXS,
                                      ),
                                      Text(e.label ?? ""),
                                      const SizedBox(
                                        height: Dimension.paddingXS,
                                      ),
                                    ],
                                  ))),
                          Divider(color: Colors.grey.shade400, height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                ))));
  }
}
