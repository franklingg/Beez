import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/feed/feed_screen.dart';
import 'package:beez/presentation/shared/hexagon_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddEvent extends StatelessWidget {
  const AddEvent({super.key});

  Future loginAlert(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(
                "Aviso do Sistema",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              content: Text(
                  "Para cadastrar e/ou interagir com eventos, além de outros usuários, é preciso fazer login no sistema.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.justify),
              actions: [
                TextButton(
                    onPressed: () {
                      GoRouter.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 5,
      bottom: 20,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
            onTap: () {
              if (FirebaseAuth.instance.currentUser == null) {
                loginAlert(context);
              } else {
                GoRouter.of(context).pushNamed(FeedScreen.name);
              }
            },
            child: const Hexagon(
                child: Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.add_rounded, size: 30, color: AppColors.black),
            )))
      ]),
    );
  }
}
