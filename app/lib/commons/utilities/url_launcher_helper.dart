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

import 'package:url_launcher/url_launcher_string.dart';

class UrlLauncherHelper {
  static void launchUrl(UrlTypes type, String url) {
    switch (type) {
      case UrlTypes.tel:
        _launchURL(UrlTypes.tel.name, url);
        break;
      case UrlTypes.whatsapp:
        _launchURL('https://wa.me/', url, addEndSlashes: false);
        break;
      case UrlTypes.sms:
        _launchURL(UrlTypes.sms.name, url);
        break;
      default:
        _launchURL('https', url);
        break;
    }
  }

  static void _launchURL(String type, String phoneNumber, {bool addEndSlashes = true}) async {
    if (!await launchUrlString('$type:${addEndSlashes ? '//' : ''}$phoneNumber')) throw 'Could not launch $type:$phoneNumber';
  }
}

enum UrlTypes { whatsapp, tel, sms }
