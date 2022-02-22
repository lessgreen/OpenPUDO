/*
 OpenPUDO - PUDO and Micro-delivery software for Last Mile Collaboration
 Copyright (C) 2020-2022 LESS SRL - https://less.green

 This file is part of OpenPUDO software.

 OpenPUDO is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License version 3
 as published by the Copyright Owner.

 OpenPUDO is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License version 3 for more details.

 You should have received a copy of the GNU Affero General Public License
 version 3 published by the Copyright Owner along with OpenPUDO.
 If not, see <https://github.com/lessgreen/OpenPUDO>.
*/

import 'package:flutter/material.dart' show BoxShadow, Color, Colors, Offset;

class Dimension {
  static const paddingXS = 4.0;
  static const paddingS = 8.0;
  static const padding = 16.0;
  static const paddingM = 32.0;
  static const paddingL = 42.0;
  static const paddingXL = 56.0;
  static const paddingXXL = 88.0;
  static const loginLayoutPadding = 44.0;

  static const minButtonHeight = 48.0;
  static const minButtonWidth = 256.0;

  static const titleFontSize = 32.0;
  static const body2FontSize = 14.0;
  static const body1FontSize = 16.0;
  static const fontSizeS = 18.0;
  static const captionFontSize = 12.0;
  static const fontSize = 20.0;
  static const fontSizeL = 22.0;
  static const fontSizeXXL = 26.0;
  static const subtitleFontSize = 20.0;

  static const borderRadiusS = 10.0;
  static const borderRadius = 30.0;
  static const borderRadiusSearch = 25.0;

  static const chipIcon = 16.0;
  static const illustrationHeight = 120.0;

  static const height = 50.0;
  static const autocompleteMaxHeight = 250.0;

  static const letterSpacing = 0.7;

  static const maxImageBytes = 700000;
  static const maxImageBytesBig = 1000000;
}

class ImageSrc {
  static const welcomeScreen = "assets/welcomeScreen.svg";
  static const smsArt = "assets/smsArt.svg";
  static const insertPhoneArt = "assets/insertPhoneArt.svg";
  static const aboutYouArt = "assets/aboutYouArt.svg";
  static const userPositionArt = "assets/userPositionArt.svg";
  static const imagePlaceHolder = "assets/placeholderImage.jpg";
  static const imageSVGPlaceHolder = "assets/placeholder.svg";
  static const mapsArt = "assets/Map.svg";
  static const homeArt = "assets/Home.svg";
  static const profileArt = "assets/Profile.svg";
  static const searchArt = "assets/Search.svg";
  static const shareArt = "assets/Share.svg";
  static const leaf = "assets/leaf.svg";
  static const chevronRight = "assets/chevron_right.svg";
  static const emptyBox = "assets/boxEmpty.svg";
  static const fillBox = "assets/boxFill.svg";

  //new icons
  static const positionLeadingCell = "assets/positionLeadingCell.svg";
  static const packageDeliveredLeadingIcon = "assets/packageDeliveredLeadingIcon.svg";
  static const waitingShipmentLeadingIcon = "assets/waitingShipmentLeadingIcon.svg";
  static const packReceivedLeadingIcon = "assets/packReceivedLeadingIcon.svg";
  static const shipmentLeadingCell = "assets/shipmentLeadingCell.svg";
  static const launcherIcon = "assets/launcherIcon.svg";
  static const logoutIcon = "assets/logoutIcon.svg";
  static const doneUserOnboarding = "assets/doneUserOnboarding.svg";
  static const notificationVectorArt = "assets/notificationVectorArt.svg";
  static const noPudoYet = "assets/noPudoYet.svg";
  static const noPackagesYet = "assets/noPackagesYet.svg";
  static const welcomePudoOnboarding = "assets/welcomePudoOnboarding.svg";
  static const phoneIcon = "assets/phoneIcon.svg";
  static const phoneIconFill = "assets/phoneIconFill.svg";
}

class IconSrc {}

class AppColors {
  static const primarySwatch = Color(0xFFA0B92C);
  static const accentColor = Color(0xFFA0B92C);
  static const cardColor = Color(0xFFA0B92C);
  static const primaryColorDark = Color(0xFFA0B92C);
  static const primaryTextColor = Color(0xFF363736);
  static const colorGrey = Color(0xFF979797);
  static const labelLightDark = Color(0x23373737);
  static const labelDark = Color(0xFF373737);
}

class Shadows {
  static final baseShadow = [
    BoxShadow(
      color: Colors.black.withAlpha(50),
      blurRadius: 5.0,
      spreadRadius: 0.2,
      offset: const Offset(
        0.0,
        0.0,
      ),
    )
  ];
}
