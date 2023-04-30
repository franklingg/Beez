import 'package:beez/constants/app_colors.dart';
import 'package:beez/presentation/user/login_screen.dart';
import 'package:beez/services/user_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserMenu extends StatelessWidget {
  const UserMenu({super.key});

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
        menuItemBuilder(
            context,
            Icons.calendar_month_outlined,
            "Meus Eventos",
            // TODO: NAVIGATE TO MY EVENTS
            () {}),
        menuItemBuilder(
            context,
            Icons.person_outline,
            "Edital Perfil",
            // TODO: NAVIGATE TO PROFILE EDITION
            () {}),
        menuItemBuilder(
            context,
            Icons.share,
            "Compartilhar Perfil",
            // TODO: SHARE DEEP LINK
            () {}),
        menuItemBuilder(context, Icons.logout, "Sair", () {
          UserService.performLogout();
          GoRouter.of(context).pushReplacementNamed(LoginScreen.name);
        }),
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
