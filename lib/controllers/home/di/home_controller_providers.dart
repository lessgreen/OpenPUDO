import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/home/viewmodel/home_controller_viewmodel.dart';
import 'package:qui_green/controllers/user_position/viewmodel/user_position_controller_viewmodel.dart';

List<SingleChildWidget> homeControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<HomeControllerViewModel?>(
      create: (context) => HomeControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
