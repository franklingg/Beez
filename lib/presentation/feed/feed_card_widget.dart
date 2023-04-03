import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_images.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/presentation/event/event_screen.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/profile_item_widget.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:beez/services/event_service.dart';
import 'package:beez/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FeedCard extends StatelessWidget {
  final EventModel data;
  final double? distanceFromUser;
  const FeedCard({super.key, required this.data, this.distanceFromUser});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (_, userProvider, __) {
      final creatorData = userProvider.getUser(data.creator);
      final currentUserFollows =
          creatorData.followers.contains(userProvider.currentUserId);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: ProfileItem(user: creatorData, iconSize: 21)),
              GestureDetector(
                  onTap: () {
                    if (userProvider.currentUserId == null) {
                      AppAlerts.login(alertContext: context);
                    } else if (userProvider.currentUserId != creatorData.id) {
                      UserService.toggleFollowers(
                          creatorData, userProvider.currentUserId!);
                    } else {
                      AppAlerts.error(
                          alertContext: context,
                          errorMessage: "Não é possível seguir a si mesmo.");
                    }
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: currentUserFollows
                              ? AppColors.lightGreen
                              : AppColors.lightBlue,
                          border: currentUserFollows
                              ? Border.all(color: AppColors.green)
                              : Border.all(width: 0),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(currentUserFollows ? "Seguindo" : "Seguir",
                          style: TextStyle(
                              color: currentUserFollows
                                  ? AppColors.green
                                  : AppColors.white,
                              fontSize: 14)))),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
              onTap: () {
                GoRouter.of(context)
                    .pushNamed(EventScreen.name, queryParams: {'id': data.id});
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image(
                            image: data.photos.isEmpty
                                ? AssetImage(AppImages.placeholder)
                                    as ImageProvider
                                : NetworkImage(data.photos[0]))),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                          text:
                              "${DateFormat("dd/MM/yyyy").format(data.date.toDate())} - ${data.date.toDate().hour}h - ${distanceFromUser != null ? distanceFromUser!.toStringAsFixed(1) : '?'} km - ",
                          style: Theme.of(context).textTheme.displaySmall,
                          children: [
                            TextSpan(
                                text: data.isFree ? "Gratuito" : "Evento Pago",
                                style: TextStyle(
                                    color: data.isFree
                                        ? AppColors.green
                                        : AppColors.blue))
                          ]),
                    ),
                    const SizedBox(height: 7),
                    Text(data.description,
                        style: Theme.of(context).textTheme.labelSmall),
                  ])),
          const SizedBox(height: 7),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
              onTap: () {
                if (userProvider.currentUserId == null) {
                  AppAlerts.login(alertContext: context);
                } else if (data.creator != userProvider.currentUserId) {
                  EventService.toggleLikeEvent(
                      data, userProvider.currentUserId!);
                } else {
                  AppAlerts.error(
                      alertContext: context,
                      errorMessage:
                          "Não é possível se interessar pelo seu próprio evento.");
                }
              },
              child: data.interested.contains(userProvider.currentUserId)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                          Icon(
                            Icons.person_pin_circle_rounded,
                            size: 25,
                            color: AppColors.darkYellow,
                          ),
                          Text("Tenho Interesse",
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.darkYellow))
                        ])
                  : Row(children: const [
                      Icon(
                        Icons.person_pin_circle_outlined,
                        size: 25,
                        color: AppColors.darkYellow,
                      ),
                      Text(
                        "Tenho Interesse",
                        style: TextStyle(fontSize: 12, color: AppColors.black),
                      )
                    ]),
            ),
            Expanded(
              child: GestureDetector(
                  onTap: () {
                    // TODO: DEEP LINK SHARE
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.share,
                          size: 20,
                          color: AppColors.black,
                        ),
                        Text(
                          "Compartilhar",
                          style:
                              TextStyle(fontSize: 12, color: AppColors.black),
                        )
                      ])),
            ),
            GestureDetector(
              onTap: () {
                AppAlerts.userList(
                    alertContext: context,
                    title: "Interessados",
                    userList: data.interested
                        .map((uid) => userProvider.getUser(uid))
                        .toList());
              },
              child: Row(
                children: [
                  data.interested.isNotEmpty
                      ? SizedBox(
                          width: 30,
                          child: Stack(
                            children: [
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundImage: NetworkImage(userProvider
                                      .getUser(data.interested.first)
                                      .profilePic),
                                ),
                              ),
                              if (data.interested.length > 1)
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundImage: NetworkImage(userProvider
                                        .getUser(data.interested[1])
                                        .profilePic),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : Container(),
                  const SizedBox(width: 3),
                  Text(
                    "${data.interested.length} interessado${data.interested.length == 1 ? '' : 's'}",
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.black),
                  )
                ],
              ),
            )
          ]),
          const SizedBox(height: 15)
        ],
      );
    });
  }
}
