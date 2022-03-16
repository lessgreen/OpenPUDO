import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/commons/utilities/localization.dart';
import 'package:qui_green/resources/res.dart';

class PudoEditableImage extends StatelessWidget {
  final bool editEnabled;
  final File? selectedImage;
  final String? picId;
  final Function() onTap;

  const PudoEditableImage({Key? key, this.selectedImage, this.picId, required this.editEnabled, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 18 / 9,
          child: editEnabled && selectedImage != null
              ? Image.file(
                  selectedImage!,
                  fit: BoxFit.cover,
                )
              : CustomNetworkImage(
                  url: picId,
                  height: 2000,
                  fit: BoxFit.fitWidth,
                ),
        ),
        if (editEnabled)
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                alignment: Alignment.center,
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(50),
                      borderRadius: BorderRadius.circular(Dimension.borderRadiusSearch),
                      border: Border.all(
                        color: Colors.white,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.symmetric(vertical: Dimension.paddingS),
                    child: Text(
                      'changePhoto'.localized(context),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white),
                    )),
              ),
            ),
          ),
      ],
    );
  }
}
