import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/puedo_detail/viewmodel/puedo_detail_controller_viewmodel.dart';

List<SingleChildWidget> puedoDetailControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<PuedoDetailControllerViewModel?>(
      create: (context) => PuedoDetailControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
