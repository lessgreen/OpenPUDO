import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/personal_data/viewmodel/personal_data_controller_viewmodel.dart';

List<SingleChildWidget> personalDataControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<PersonalDataControllerViewModel?>(
      create: (context) => PersonalDataControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
