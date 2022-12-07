import 'package:qui_green/models/dynamiclink_response.dart';

class DynamicLinkManager {
  static final DynamicLinkManager _singleton = DynamicLinkManager._internal();
  DynamicLinkResponse? dynamicLink;
  String? magicLinkId;

  factory DynamicLinkManager() {
    return _singleton;
  }

  DynamicLinkManager._internal();
}
