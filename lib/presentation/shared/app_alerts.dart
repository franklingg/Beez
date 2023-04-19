import 'package:beez/models/user_model.dart';
import 'package:beez/utils/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppAlerts {
  BuildContext alertContext;
  late String title;
  String? content;
  List<UserModel>? userList;

  AppAlerts.login({required this.alertContext}) {
    title = "Aviso do Sistema";
    content =
        "Para cadastrar e/ou interagir com eventos, além de outros usuários, é preciso fazer login no sistema.";

    showAlert();
  }

  AppAlerts.userList(
      {required this.alertContext,
      required this.title,
      required List<String> userIds}) {
    Consumer<UserProvider>(builder: (_, userProvider, __) {
      userList = userProvider.allUsers
          .where((user) => userIds.contains(user.id))
          .toList();
      return Container();
    });
    showAlert();
  }

  Future showAlert() {
    return showDialog(
        context: alertContext,
        builder: (ctx) => AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(alertContext).textTheme.titleMedium,
              ),
              content: Text(content ?? "",
                  style: Theme.of(alertContext).textTheme.bodyMedium,
                  textAlign: TextAlign.justify),
              actions: [
                TextButton(
                    onPressed: () {
                      GoRouter.of(alertContext).pop();
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(fontSize: 16),
                    ))
              ],
              contentPadding:
                  const EdgeInsets.only(left: 20, right: 20, top: 10),
              actionsAlignment: MainAxisAlignment.center,
            ));
  }
}
