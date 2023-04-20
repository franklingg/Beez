import 'dart:math';

import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/user_model.dart';
import 'package:beez/presentation/profile/profile_screen.dart';
import 'package:beez/presentation/shared/profile_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppAlerts {
  BuildContext alertContext;
  late String title;
  String? content;
  List<UserModel>? userList;

  AppAlerts.login({required this.alertContext}) {
    title = "Aviso do Sistema";
    content =
        "Para cadastrar e/ou interagir com eventos, além de outros usuários, é preciso fazer login no sistema. \nAcesse \"Perfil\" para fazer login.";

    showAlert();
  }

  AppAlerts.userList(
      {required this.alertContext,
      required this.title,
      required List<UserModel> this.userList}) {
    showAlert();
  }

  Future showAlert() {
    return showDialog(
        context: alertContext,
        builder: (ctx) => AlertDialog(
              titlePadding: const EdgeInsets.all(12),
              actionsPadding: EdgeInsets.zero,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        title,
                        style: Theme.of(alertContext).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(alertContext).pop();
                    },
                    child: const Icon(Icons.close_rounded,
                        size: 22, color: AppColors.mediumGrey),
                  )
                ],
              ),
              content: content != null
                  ? Text(content!,
                      style: Theme.of(alertContext).textTheme.bodyMedium,
                      textAlign: TextAlign.justify)
                  : SizedBox(
                      height: min(50.0 * userList!.length, 270),
                      child: ListView.builder(
                          itemCount: userList!.length,
                          itemBuilder: (context, index) {
                            return Column(children: [
                              ProfileItem(user: userList![index]),
                              const SizedBox(height: 10)
                            ]);
                          }),
                    ),
              actions: content != null
                  ? [
                      TextButton(
                          onPressed: () {
                            GoRouter.of(alertContext).pop();
                          },
                          child: const Text(
                            "OK",
                            style: TextStyle(fontSize: 16),
                          ))
                    ]
                  : [],
              contentPadding:
                  const EdgeInsets.only(left: 20, right: 20, top: 10),
              actionsAlignment: MainAxisAlignment.center,
            ));
  }
}
