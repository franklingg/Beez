import 'package:beez/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppField extends StatelessWidget {
  final Widget child;
  const AppField({super.key, required this.child});

  static InputDecoration inputDecoration(
      {required String hint, Widget? suffix}) {
    return InputDecoration(
        contentPadding: EdgeInsets.zero,
        hintStyle: const TextStyle(
            height: 0.5, fontSize: 14, color: AppColors.mediumGrey),
        border: InputBorder.none,
        hintText: hint,
        errorMaxLines: 2,
        errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(width: 1, color: AppColors.grey)),
        focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(width: 1, color: AppColors.grey)),
        suffixIcon: suffix,
        suffixIconConstraints:
            const BoxConstraints(maxHeight: 25, maxWidth: 25));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 11, right: 7),
        decoration:
            BoxDecoration(border: Border.all(color: AppColors.grey, width: 2)),
        child: child);
  }
}
