import 'package:latlong2/latlong.dart';
import 'package:qui_green/models/pudo_profile.dart';

class PudoDetailControllerDataModel{
  final LatLng initialPosition;
  final PudoProfile pudoProfile;

  const PudoDetailControllerDataModel(this.initialPosition, this.pudoProfile);
}