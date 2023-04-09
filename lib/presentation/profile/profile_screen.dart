import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/profile/user_menu_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/carousel_widget.dart';
import 'package:beez/providers/event_provider.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:beez/services/user_service.dart';
import 'package:beez/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  static const name = "profile";
  final String? id;
  const ProfileScreen({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (_, userProvider, __) {
      final userData = userProvider.getUser(id!);
      return Consumer<EventProvider>(builder: (_, eventProvider, __) {
        final eventsUserCreated = eventProvider.allEvents
            .where((event) => event.creator == userData.id);
        final eventsUserParticipated = eventProvider.allEvents
            .where((event) => event.interested.contains(userData.id));
        return SafeArea(
            child: Scaffold(
          body: SingleChildScrollView(
            child: Column(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(25))),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => GoRouter.of(context).pop(),
                          child:
                              const Icon(Icons.arrow_back_outlined, size: 25),
                        ),
                        // TODO: Verify if currentuser is page id user
                        true ? const UserMenu() : const SizedBox()
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10, left: 5, right: 5),
                        child: Row(children: [
                          CircleAvatar(
                            backgroundColor: AppColors.brown,
                            radius: 61,
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(userData.profilePic),
                              radius: 60,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                  userData.name.toTitleCase(),
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 15),
                                Row(children: [
                                  Text(
                                      "${userData.followers.length.toString()}\nSeguidores",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  const SizedBox(width: 7),
                                  Text(
                                      "${userData.following.length.toString()}\nSeguindo",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  const SizedBox(width: 7),
                                  Text("${eventsUserCreated.length}\nEventos",
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(context).textTheme.bodySmall)
                                ]),
                                const SizedBox(height: 10),
                                //TODO: Verify if current user is this id profile user
                                true
                                    ? Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                                style: const ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            AppColors.white)),
                                                // TODO: FOLLOW
                                                onPressed: () {
                                                  if (UserService.currentUser ==
                                                      null) {
                                                    AppAlerts.login(
                                                        alertContext: context);
                                                  }
                                                },
                                                child: Text(
                                                  "Seguir",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                )),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: const ButtonStyle(
                                                padding:
                                                    MaterialStatePropertyAll(
                                                        EdgeInsets.zero),
                                                minimumSize:
                                                    MaterialStatePropertyAll(
                                                        Size(35, 35)),
                                                backgroundColor:
                                                    MaterialStatePropertyAll(
                                                        AppColors.white)),
                                            //TODO: SHARE DEEP LINK
                                            onPressed: () {},
                                            child: const Icon(
                                              Icons.share,
                                              size: 22,
                                              color: AppColors.black,
                                            ),
                                          )
                                        ],
                                      )
                                    : const SizedBox()
                              ]))
                        ]))
                  ])),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  children: [
                    eventsUserCreated.isEmpty
                        ? const SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                  "Eventos Organizados",
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 10),
                                Carousel(
                                    isMultipleEvent: true,
                                    multipleEvents: eventsUserCreated.toList()),
                                const SizedBox(height: 30)
                              ]),
                    eventsUserParticipated.isEmpty
                        ? const SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                  "Eventos Participados",
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 10),
                                Carousel(
                                    isMultipleEvent: true,
                                    multipleEvents:
                                        eventsUserParticipated.toList())
                              ]),
                  ],
                ),
              ),
            ]),
          ),
          bottomNavigationBar: const TabNavigation(),
        ));
      });
    });
  }
}
