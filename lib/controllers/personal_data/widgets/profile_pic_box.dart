import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qui_green/resources/res.dart';

class ProfilePicBox extends StatelessWidget {
  final Function() onTap;
  final File? image;

  const ProfilePicBox({Key? key, required this.onTap, this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius:
            const BorderRadius.all(Radius.circular(Dimension.borderRadius)),
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          height: MediaQuery.of(context).size.width / 3,
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.all(
                  Radius.circular(Dimension.borderRadius))),
          child: image != null
              ? ClipRRect(
                  borderRadius: const BorderRadius.all(
                      Radius.circular(Dimension.borderRadius)),
                  child: Image.file(
                    image!,
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.account_circle_rounded,
                      color: Colors.grey.shade400,
                      size: MediaQuery.of(context).size.width / 6,
                    ),
                    Text(
                      'Aggiungi una \ntua foto',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
        ),
      );
}
