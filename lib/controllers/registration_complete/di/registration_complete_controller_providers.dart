import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/registration_complete/viewmodel/registration_complete_controller_viewmodel.dart';

List<SingleChildWidget> registrationCompleteControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<RegistrationCompleteControllerViewModel?>(
      create: (context) => RegistrationCompleteControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
