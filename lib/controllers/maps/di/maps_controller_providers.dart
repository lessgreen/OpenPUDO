import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/maps/viewmodel/maps_controller_viewmodel.dart';

List<SingleChildWidget> mapsControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<MapsControllerViewModel?>(
      create: (context) => MapsControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
