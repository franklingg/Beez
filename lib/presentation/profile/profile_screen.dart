import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/models/user_model.dart';
import 'package:beez/presentation/login/login_screen.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/profile/user_menu_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/carousel_widget.dart';
import 'package:beez/providers/event_provider.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:beez/services/auth_service.dart';
import 'package:beez/services/user_service.dart';
import 'package:beez/utils/extensions.dart';
import 'package:beez/utils/links_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:beez/presentation/shared/loading_widget.dart';

class ProfileScreen extends StatefulWidget {
  static const name = "profile";
  final String? id;
  const ProfileScreen({super.key, this.id});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      Provider.of<UserProvider>(context, listen: false).addListener(() {
        try {
          setState(() {});
          // ignore: empty_catches
        } catch (e) {}
      });
    });
  }

  void handleLogout() {
    setState(() {
      isLoading = true;
    });
    AuthService.performLogout();
    GoRouter.of(context).pushReplacementNamed(LoginScreen.name);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (_, userProvider, __) {
      final userData = userProvider.getUser(widget.id!);
      final currentUserFollows =
          userData.followers.contains(userProvider.currentUserId);
      return Consumer<EventProvider>(builder: (_, eventProvider, __) {
        List<UserModel> userFollowers = userProvider.allUsers
            .where((user) => userData.followers.contains(user.id))
            .toList();
        List<UserModel> userFollowing = userProvider.allUsers
            .where((user) => user.followers.contains(widget.id))
            .toList();
        List<EventModel> eventsUserCreated =
            userProvider.shouldShowEvents(userId: userData.id)
                ? eventProvider.allEvents
                    .where((event) => event.creator == userData.id)
                    .toList()
                : [];
        List<EventModel> eventsUserParticipated =
            userProvider.shouldShowEvents(userId: userData.id)
                ? eventProvider.allEvents
                    .where((event) => event.interested.contains(userData.id))
                    .toList()
                : [];
        return SafeArea(
            child: Loading(
          isLoading: isLoading,
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
                          if (userProvider.currentUserId == widget.id)
                            UserMenu(
                                onLogout: handleLogout,
                                onShare: () => LinksUtil.shareUser(userData))
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
                                backgroundImage: userProvider.getProfilePic(
                                    userId: userData.id),
                                radius: 60,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                    userData.name.toTitleCase(),
                                    maxLines: 2,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 15),
                                  Row(children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (userFollowers.isNotEmpty) {
                                          AppAlerts.userList(
                                              alertContext: context,
                                              title: "Seguidores",
                                              userList: userFollowers);
                                        }
                                      },
                                      child: Text(
                                          "${userData.followers.length.toString()}\nSeguidores",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ),
                                    const SizedBox(width: 7),
                                    GestureDetector(
                                        onTap: () {
                                          if (userFollowing.isNotEmpty) {
                                            AppAlerts.userList(
                                                alertContext: context,
                                                title: "Seguindo",
                                                userList: userFollowing);
                                          }
                                        },
                                        child: Text(
                                            "${userFollowing.length}\nSeguindo",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall)),
                                    const SizedBox(width: 7),
                                    Text("${eventsUserCreated.length}\nEventos",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall)
                                  ]),
                                  const SizedBox(height: 10),
                                  if (userProvider.currentUserId != widget.id)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                              style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          AppColors.white)),
                                              onPressed: () {
                                                if (userProvider
                                                        .currentUserId ==
                                                    null) {
                                                  AppAlerts.login(
                                                      alertContext: context);
                                                } else {
                                                  UserService.toggleFollowers(
                                                      userData,
                                                      userProvider
                                                          .currentUserId!);
                                                }
                                              },
                                              child: Text(
                                                currentUserFollows
                                                    ? "Seguindo"
                                                    : "Seguir",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color:
                                                            currentUserFollows
                                                                ? AppColors
                                                                    .green
                                                                : null),
                                              )),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: const ButtonStyle(
                                              padding: MaterialStatePropertyAll(
                                                  EdgeInsets.zero),
                                              minimumSize:
                                                  MaterialStatePropertyAll(
                                                      Size(35, 35)),
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      AppColors.white)),
                                          onPressed: () =>
                                              LinksUtil.shareUser(userData),
                                          child: const Icon(
                                            Icons.share,
                                            size: 22,
                                            color: AppColors.black,
                                          ),
                                        )
                                      ],
                                    )
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge,
                                  ),
                                  const SizedBox(height: 10),
                                  Carousel(
                                      isMultipleEvent: true,
                                      multipleEvents: eventsUserCreated),
                                  const SizedBox(height: 30)
                                ]),
                      eventsUserParticipated.isEmpty
                          ? const SizedBox()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    "Eventos de Interesse",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge,
                                  ),
                                  const SizedBox(height: 10),
                                  Carousel(
                                      isMultipleEvent: true,
                                      multipleEvents: eventsUserParticipated)
                                ]),
                    ],
                  ),
                ),
              ]),
            ),
            bottomNavigationBar: const TabNavigation(),
          ),
        ));
      });
    });
  }
}
