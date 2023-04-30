import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/carousel_widget.dart';
import 'package:beez/presentation/shared/profile_item_widget.dart';
import 'package:beez/providers/event_provider.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventScreen extends StatelessWidget {
  static const String name = 'event';
  final String? id;
  const EventScreen({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<UserProvider>(builder: (_, userProvider, __) {
        return Scaffold(
          body: Consumer<EventProvider>(
            builder: (_, eventProvider, __) {
              final event = eventProvider.getEvent(id!);
              return Column(children: [
                Carousel(isMultipleEvent: false, singleEvent: event),
                Padding(
                    padding:
                        const EdgeInsets.only(top: 12, left: 15, right: 15),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(event.name,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                                text:
                                    "${DateFormat("dd/MM/yyyy").format(event.date.toDate())} - ${event.date.toDate().hour}h - ",
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                      text: event.isFree
                                          ? "Gratuito"
                                          : "Evento Pago",
                                      style: TextStyle(
                                          color: event.isFree
                                              ? AppColors.green
                                              : AppColors.blue))
                                ]),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            event.description,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 7),
                          Text(
                            event.address,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 7),
                          Row(children: [
                            GestureDetector(
                              onTap: () {
                                // TODO: CURRENT USER LIKE
                                if (userProvider.currentUserId == null) {
                                  AppAlerts.login(alertContext: context);
                                }
                              },
                              child: event.interested
                                      .contains(userProvider.currentUserId)
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: const [
                                          Icon(
                                            Icons.person_pin_circle_rounded,
                                            size: 30,
                                            color: AppColors.darkYellow,
                                          ),
                                          SizedBox(width: 3),
                                          Text("Tenho Interesse",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.darkYellow))
                                        ])
                                  : Row(children: const [
                                      Icon(
                                        Icons.person_pin_circle_outlined,
                                        size: 30,
                                        color: AppColors.darkYellow,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        "Tenho Interesse",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.black),
                                      )
                                    ]),
                            ),
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    // TODO: DEEP LINK SHARE
                                  },
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.share,
                                          size: 23,
                                          color: AppColors.black,
                                        ),
                                        SizedBox(width: 7),
                                        Text(
                                          "Compartilhar",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.black),
                                        )
                                      ])),
                            )
                          ]),
                          const SizedBox(height: 10),
                          Text("Lista de Interessados",
                              style: Theme.of(context).textTheme.displayMedium),
                          const SizedBox(height: 7),
                          SizedBox(
                            height: 75,
                            child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  mainAxisExtent: 40,
                                  mainAxisSpacing: 10,
                                  crossAxisCount: 2,
                                ),
                                itemCount: event.interested.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ProfileItem(
                                            user: userProvider.getUser(
                                                event.interested[index]))
                                      ]);
                                }),
                          )
                        ]))
              ]);
            },
          ),
          bottomNavigationBar: const TabNavigation(),
        );
      }),
    );
  }
}
