import 'package:beez/models/user_model.dart';
import 'package:beez/presentation/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileItem extends StatelessWidget {
  final UserModel user;
  final double iconSize;
  const ProfileItem({super.key, required this.user, this.iconSize = 20});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).goNamed(ProfileScreen.name);
      },
      child: Row(
        children: [
          CircleAvatar(
              radius: iconSize, backgroundImage: NetworkImage(user.profilePic)),
          const SizedBox(width: 15),
          Expanded(
              child: Text(
            user.name,
            style: Theme.of(context).textTheme.bodyMedium,
          )),
        ],
      ),
    );
  }
}
