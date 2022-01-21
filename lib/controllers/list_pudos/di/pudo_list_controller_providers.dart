import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/list_pudos/viewmodel/pudo_list_controller_viewmodel.dart';

List<SingleChildWidget> pudoListControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<PudoListControllerViewModel?>(
      create: (context) => PudoListControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
