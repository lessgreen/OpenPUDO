import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/user_position/viewmodel/user_position_controller_viewmodel.dart';

List<SingleChildWidget> userPositionControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<UserPositionControllerViewModel?>(
      create: (context) => UserPositionControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
