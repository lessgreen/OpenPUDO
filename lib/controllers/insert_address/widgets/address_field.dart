import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qui_green/controllers/insert_address/viewmodel/insert_address_controller_viewmodel.dart';
import 'package:qui_green/controllers/insert_address/widgets/address_overlay.dart';
import 'package:qui_green/resources/res.dart';

class AddressField extends StatefulWidget {
  InsertAddressControllerViewModel viewModel;
  final FocusNode node;

  AddressField({Key? key, required this.viewModel, required this.node})
      : super(key: key);

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  late OverlayEntry overlayEntry;
  bool overlayCreated = false;

  void removeOverlay() {
    overlayCreated = false;
    overlayEntry.remove();
  }

  void _showOverlay(
      {required InsertAddressControllerViewModel viewModel,
      required BuildContext context,
      required double top,
      required double left,
      required double width}) async {
    if (!overlayCreated) {
      OverlayState? overlayState = Overlay.of(context);

      overlayEntry = OverlayEntry(builder: (context) {
        return AddressOverlay(
          viewModel: viewModel,
          positionLeft: left,
          positionTop: top,
          width: width,
          onSelect: (val) {
            viewModel.isSelectingFromOverlay = true;
            viewModel.addressController.text = val!;
            Future.delayed(const Duration(milliseconds: 100),
                () => viewModel.isSelectingFromOverlay = false);
            removeOverlay();
          },
          removeOverlay: removeOverlay,
        );
      });
      overlayCreated = true;
      overlayState?.insert(overlayEntry);
    }
  }

  final GlobalKey _key = GlobalKey();

  void onAfter() {
    _key.currentContext?.size?.width;
    final RenderBox renderBox =
        _key.currentContext?.findRenderObject() as RenderBox;
    Offset? positionRed = renderBox.localToGlobal(Offset.zero);
    double top = (positionRed.dy) + (_key.currentContext?.size?.height ?? 0);
    _showOverlay(
        context: context,
        top: top + Dimension.paddingXS,
        width: _key.currentContext?.size?.width ?? 0,
        left: positionRed.dx,
        viewModel: widget.viewModel);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      key: _key,
      controller: widget.viewModel.addressController,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).primaryColor))),
      autofocus: false,
      focusNode: widget.node,
      textInputAction: TextInputAction.done,
      onChanged: (newValue) {
        if (!widget.viewModel.isSelectingFromOverlay) {
          widget.viewModel.onSearchChanged(newValue, onAfter);
        }
      },
    );
  }
}
