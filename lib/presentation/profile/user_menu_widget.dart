import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/event/my_events_screen.dart';
import 'package:beez/presentation/profile/edit_profile_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserMenu extends StatelessWidget {
  final void Function() onLogout;
  const UserMenu({super.key, required this.onLogout});

  DropdownMenuItem<Function> menuItemBuilder(
      BuildContext context, IconData icon, String text, Function function) {
    return DropdownMenuItem<Function>(
        value: function,
        child: Row(children: [
          Icon(
            icon,
            size: 23,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
        child: DropdownButton2(
      customButton: const Icon(
        Icons.more_vert_outlined,
        size: 25,
        color: AppColors.black,
      ),
      items: [
        menuItemBuilder(context, Icons.calendar_month_outlined, "Meus Eventos",
            () {
          GoRouter.of(context).pushNamed(MyEventsScreen.name);
        }),
        menuItemBuilder(context, Icons.person_outline, "Edital Perfil", () {
          GoRouter.of(context).pushNamed(EditProfileScreen.name);
        }),
        menuItemBuilder(
            context,
            Icons.share,
            "Compartilhar Perfil",
            // TODO: SHARE DEEP LINK
            () {}),
        menuItemBuilder(context, Icons.logout, "Sair", onLogout),
      ],
      onChanged: (valueFunction) {
        if (valueFunction != null) valueFunction();
      },
      dropdownStyleData: DropdownStyleData(
        width: 190,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      ),
      menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.zero),
    ));
  }
}
