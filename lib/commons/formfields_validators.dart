//
//   formfields_validators.dart
//   OpenPudo
//
//   Created by Costantino Pistagna on Tue Jan 25 2022
//   Copyright © 2022 Sofapps.it - All rights reserved.
//

extension FormFieldValidators on String {
  bool isValidPhoneNumber() {
    String pattern = r'(^(?:[+0]9)?[0-9]{8,}$)';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(this);
  }
}
