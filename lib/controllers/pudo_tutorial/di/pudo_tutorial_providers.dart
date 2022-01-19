import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/pudo_tutorial/viewmodel/pudo_tutorial_viewmodel.dart';

List<SingleChildWidget> pudoTutorialProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<PudoTutorialViewModel?>(
      create: (context) => PudoTutorialViewModel(),
      update: (context, viewModel) => viewModel),
];
