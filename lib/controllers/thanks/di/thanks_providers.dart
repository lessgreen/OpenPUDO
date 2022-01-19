import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/thanks/viewmodel/thanks_viewmodel.dart';

List<SingleChildWidget> thanksControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<ThanksControllerViewModel?>(
      create: (context) => ThanksControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
