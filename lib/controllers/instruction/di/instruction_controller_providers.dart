import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:qui_green/controllers/instruction/viewmodel/instruction_controller_viewmodel.dart';
import 'package:qui_green/controllers/registration_complete/viewmodel/registration_complete_controller_viewmodel.dart';

List<SingleChildWidget> instructionControllerProviders = [
  ..._dependentServices,
];

List<SingleChildWidget> _dependentServices = [
  ChangeNotifierProxyProvider0<InstructionControllerViewModel?>(
      create: (context) => InstructionControllerViewModel(),
      update: (context, viewModel) => viewModel),
];
