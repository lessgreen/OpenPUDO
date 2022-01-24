//
//  profile_controller.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 04/01/2022.
//  Copyright © 2022 Sofapps. All rights reserved.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/widgets/base_page.dart';
import 'package:qui_green/controllers/profile/viewmodel/profile_controller_viewmodel.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';

class ProfileController extends StatefulWidget {
  const ProfileController({Key? key}) : super(key: key);

  @override
  _ProfileControllerState createState() => _ProfileControllerState();
}

class _ProfileControllerState extends State<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProxyProvider0<ProfileControllerViewModel?>(
          create: (context) => ProfileControllerViewModel(),
          update: (context, viewModel) => viewModel),],
      child: Consumer<ProfileControllerViewModel>(builder: (_, viewModel, __) {
        return BasePage(
          title: 'Il tuo profilo',
          showBackIcon: true,
          onPressedBack: () => Navigator.of(context).pushReplacementNamed(Routes.home),
          headerVisible: true,
          icon: const Icon(Icons.edit),
          onPressedIcon: () => null,
          index: 0,
          body: Column(
            children: [
              const SizedBox(height: 20),
              const Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(
                      'https://i1.sndcdn.com/avatars-TlbXx1BArSO2iBM1-r5ax8A-t500x500.jpg'),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Jennifer Seed',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                'Utente dal 21/11/2021',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(
                height: 20,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '',
                  style: Theme.of(context).textTheme.bodyText2,
                  children: const [
                    TextSpan(text: "Hai usato il servizio di QuiGreen "),
                    TextSpan(
                        text: "123",
                        style: TextStyle(
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.bold)),
                    TextSpan(text: " volte,"),
                    TextSpan(text: " contribuendo a ridurre di "),
                    TextSpan(
                        text: "456kg",
                        style: TextStyle(
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.bold)),
                    TextSpan(text: " le emissioni di CO2")
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(color: Colors.grey),
              GestureDetector(
                onTap: () => viewModel.goToPudos(context),
                child: Row(
                  children: const [
                    SizedBox(width: 10),
                    Icon(
                      Icons.person_pin_circle,
                      color: AppColors.cardColor,
                    ),
                    SizedBox(width: 10),
                    Text("I tuoi pudo"),
                    Spacer(),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: AppColors.cardColor,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey),
              Row(
                children: const [
                  SizedBox(width: 10),
                  Icon(
                    Icons.new_label,
                    color: AppColors.cardColor,
                  ),
                  SizedBox(width: 10),
                  Text("Le tue spedizioni"),
                  Spacer(),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: AppColors.cardColor,
                  ),
                ],
              ),
              const Divider(color: Colors.grey),
            ],
          ),
        );
      }),
    );
  }
}
