import 'package:beez/models/user_model.dart';
import 'package:beez/presentation/profile/profile_screen.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileItem extends StatelessWidget {
  final UserModel user;
  final double iconSize;
  const ProfileItem({super.key, required this.user, this.iconSize = 20});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        GoRouter.of(context)
            .pushNamed(ProfileScreen.name, queryParams: {'id': user.id});
      },
      child: Row(
        children: [
          CircleAvatar(
              radius: iconSize,
              backgroundImage:
                  provider.getProfilePic(userId: user.id, yellow: true)),
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
