import 'dart:math';

import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/user_model.dart';
import 'package:beez/presentation/shared/profile_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ignore: constant_identifier_names
enum AlertType { LOGIN, USERLIST, ERROR }

class AppAlerts {
  late AlertType type;
  BuildContext alertContext;
  late String title;
  String? content;
  List<UserModel>? userList;

  AppAlerts.login({required this.alertContext}) {
    type = AlertType.LOGIN;
    title = "Aviso do Sistema";
    content =
        "Para cadastrar e/ou interagir com eventos, além de outros usuários, é preciso fazer login no sistema. \nAcesse \"Perfil\" para fazer login.";

    showAlert();
  }

  AppAlerts.userList(
      {required this.alertContext,
      required this.title,
      required List<UserModel> this.userList}) {
    type = AlertType.USERLIST;
    showAlert();
  }

  AppAlerts.error({required this.alertContext, required String errorMessage}) {
    type = AlertType.ERROR;
    title = "Erro";
    content = errorMessage;
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
                        style: Theme.of(alertContext)
                            .textTheme
                            .titleLarge!
                            .copyWith(
                                color: type == AlertType.ERROR
                                    ? AppColors.error
                                    : null),
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
              content: type == AlertType.USERLIST
                  ? SizedBox(
                      height: min(50.0 * userList!.length, 270),
                      child: ListView.builder(
                          itemCount: userList!.length,
                          itemBuilder: (context, index) {
                            return Column(children: [
                              ProfileItem(user: userList![index]),
                              const SizedBox(height: 10)
                            ]);
                          }),
                    )
                  : Text(content!,
                      style: Theme.of(alertContext).textTheme.bodyMedium,
                      textAlign: TextAlign.justify),
              actions: type != AlertType.USERLIST
                  ? [
                      TextButton(
                          onPressed: () {
                            GoRouter.of(alertContext).pop();
                          },
                          style: ButtonStyle(
                              padding: MaterialStatePropertyAll(
                                  type == AlertType.ERROR
                                      ? const EdgeInsets.only(top: 10)
                                      : null)),
                          child: Text(
                            "OK",
                            style: TextStyle(
                                fontSize: 16,
                                color: type == AlertType.ERROR
                                    ? AppColors.error
                                    : null),
                          ))
                    ]
                  : [],
              contentPadding:
                  const EdgeInsets.only(left: 20, right: 20, top: 10),
              actionsAlignment: MainAxisAlignment.center,
            ));
  }
}
