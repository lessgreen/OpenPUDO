import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/localization.dart';

void showImageChoice(BuildContext context, Function(File?) onPicked) => SAAlertDialog.displayModalWithButtons(context, "chooseAction".localized(context, "general"), [
      CupertinoActionSheetAction(
        child: Text("shootPhoto".localized(context, "general")),
        onPressed: () => _pickImage(ImageSource.camera).then((value) => onPicked(value)),
      ),
      CupertinoActionSheetAction(
        child: Text("pickFromGallery".localized(context, "general")),
        onPressed: () => _pickImage(ImageSource.gallery).then((value) => onPicked(value)),
      ),
    ]);

Future<File?> _pickImage(ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final XFile? result = await picker.pickImage(source: source);
  if (result != null) {
    return File(result.path);
  }
  return null;
}
