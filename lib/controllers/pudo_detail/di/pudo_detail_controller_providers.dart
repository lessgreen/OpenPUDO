import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/pudo_detail/viewmodel/pudo_detail_controller_viewmodel.dart';

List<SingleChildWidget> pudoDetailControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<PudoDetailControllerViewModel?>(
      create: (context) => PudoDetailControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
