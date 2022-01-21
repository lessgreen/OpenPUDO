import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/home_pudo/viewmodel/home_pudo_controller_viewmodel.dart';

List<SingleChildWidget> homePudoControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<HomePudoControllerViewModel?>(
      create: (context) => HomePudoControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
