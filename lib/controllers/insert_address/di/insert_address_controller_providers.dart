import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/insert_address/viewmodel/insert_address_controller_viewmodel.dart';

List<SingleChildWidget> insertAddressControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<InsertAddressControllerViewModel?>(
      create: (context) => InsertAddressControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
