import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/auth/viewmodel/login_controller_viewmodel.dart';

List<SingleChildWidget> loginControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<LoginControllerViewModel?>(
      create: (context) => LoginControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
