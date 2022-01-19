import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/exchange/viewmodel/exchange_controller_viewmodel.dart';

List<SingleChildWidget> exchangeControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<ExchangeControllerViewModel?>(
      create: (context) => ExchangeControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
