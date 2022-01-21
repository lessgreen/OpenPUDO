import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/profile/viewmodel/profile_controller_viewmodel.dart';

List<SingleChildWidget> profileControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<ProfileControllerViewModel?>(
      create: (context) => ProfileControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
