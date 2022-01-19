import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/personal_data_business/viewmodel/personal_data_business_controller_viewmodel.dart';

List<SingleChildWidget> personalDataBusinessControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<PersonalDataBusinessControllerViewModel?>(
      create: (context) => PersonalDataBusinessControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
