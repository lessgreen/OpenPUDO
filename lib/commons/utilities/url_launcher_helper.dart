import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  static void launchUrl(UrlTypes type, String url) {
    switch (type) {
      case UrlTypes.tel:
        _launchURL(UrlTypes.tel.name, url);
        break;
      case UrlTypes.whatsapp:
        _launchURL('https://wa.me/', url,addEndSlashes: false);
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
    if (!await launch('$type:${addEndSlashes ? '//' : ''}$phoneNumber')) throw 'Could not launch $type:$phoneNumber';
  }
}

enum UrlTypes { whatsapp, tel, sms }
