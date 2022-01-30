/*
 OpenPUDO - PUDO and Micro-delivery software for Last Mile Collaboration
 Copyright (C) 2020-2022 LESS SRL - https://less.green

 This file is part of OpenPUDO software.

 OpenPUDO is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License version 3
 as published by the Copyright Owner.

 OpenPUDO is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License version 3 for more details.

 You should have received a copy of the GNU Affero General Public License
 version 3 published by the Copyright Owner along with OpenPUDO.  
 If not, see <https://github.com/lessgreen/OpenPUDO>.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/ui/custom_network_image.dart';
import 'package:qui_green/resources/res.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';

class ProfileController extends StatefulWidget {
  const ProfileController({Key? key}) : super(key: key);

  @override
  _ProfileControllerState createState() => _ProfileControllerState();
}

class _ProfileControllerState extends State<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUser>(builder: (_, currentUser, __) {
      return Material(
        child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              padding: const EdgeInsetsDirectional.all(0),
              brightness: Brightness.dark,
              backgroundColor: AppColors.primaryColorDark,
              middle: Text(
                'Il tuo profilo',
                style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white),
              ),
              leading: CupertinoNavigationBarBackButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CustomNetworkImage(height: 100, width: 100, fit: BoxFit.cover, url: currentUser.user?.profilePicId),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "${currentUser.user?.firstName ?? " "} ${currentUser.user?.lastName ?? " "}",
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                ),
                Text(
                  'Utente dal ${currentUser.user?.createTms ?? " "}',
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
                      TextSpan(text: "123", style: TextStyle(color: AppColors.accentColor, fontWeight: FontWeight.w500)),
                      TextSpan(text: " volte,"),
                      TextSpan(text: " contribuendo a ridurre di "),
                      TextSpan(text: "456kg", style: TextStyle(color: AppColors.accentColor, fontWeight: FontWeight.w500)),
                      TextSpan(text: " le emissioni di CO2")
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(color: Colors.grey),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacementNamed(Routes.pudoList),
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
                Material(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      NetworkManager.instance.setAccessToken(null);
                      currentUser.refresh();
                    },
                    child: Row(
                      children: const [
                        SizedBox(width: 10),
                        Icon(
                          Icons.logout,
                          color: AppColors.cardColor,
                        ),
                        SizedBox(width: 10),
                        Text("Logout"),
                        Spacer(),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: AppColors.cardColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: Colors.grey),
              ],
            )),
      );
    });
  }
}
