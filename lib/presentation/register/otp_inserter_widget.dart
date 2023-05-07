import 'package:beez/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

class OTPInserter extends StatefulWidget {
  const OTPInserter({super.key, required this.updateCode});
  final Function(String?) updateCode;

  @override
  State<OTPInserter> createState() => _OTPInserterState();
}

class _OTPInserterState extends State<OTPInserter> {
  List<String?> currentCode = List.filled(6, null, growable: false);

  Widget inserterElement(int idx) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 2, color: AppColors.shadow)),
        width: 45,
        height: 55,
        child: Center(
          child: TextFormField(
              onChanged: (value) {
                setState(() {
                  currentCode[idx] = value.isEmpty ? null : value;
                  if (currentCode.every((c) => c != null)) {
                    widget.updateCode(currentCode.join());
                  } else {
                    widget.updateCode(null);
                  }
                });
                if (value.isNotEmpty && idx != currentCode.length - 1) {
                  FocusScope.of(context).nextFocus();
                } else if (value.isEmpty && idx != 0) {
                  FocusScope.of(context).previousFocus();
                }
              },
              style: const TextStyle(color: AppColors.darkYellow, fontSize: 18),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration.collapsed(hintText: '')),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 55,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: currentCode
                .mapIndexed((idx, _) => inserterElement(idx))
                .toList()));
  }
}
