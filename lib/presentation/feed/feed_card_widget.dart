import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/profile_item_widget.dart';
import 'package:beez/utils/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      final currentUser = FirebaseAuth.instance.currentUser;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: ProfileItem(user: creatorData, iconSize: 21)),
              GestureDetector(
                  onTap: () {
                    if (currentUser == null)
                      AppAlerts.login(alertContext: context);
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Text("Seguir",
                          style: TextStyle(
                              color: AppColors.white, fontSize: 14)))),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(image: NetworkImage(data.photos[0]))),
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
                          color:
                              data.isFree ? AppColors.green : AppColors.blue))
                ]),
          ),
          const SizedBox(height: 7),
          Text(data.description, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 7),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
              onTap: () {
                if (currentUser == null) AppAlerts.login(alertContext: context);
              },
              // TODO: Verify currentUser liked
              child: false
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
            GestureDetector(
                onTap: () {},
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.ios_share_outlined,
                        size: 20,
                        color: AppColors.black,
                      ),
                      Text(
                        "Compartilhar",
                        style: TextStyle(fontSize: 12, color: AppColors.black),
                      )
                    ])),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Stack(
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundImage:
                                NetworkImage(creatorData.profilePic),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundImage:
                                NetworkImage(creatorData.profilePic),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "${data.interested.length} interessados",
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
