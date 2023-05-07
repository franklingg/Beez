import 'dart:async';

import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/user_model.dart';
import 'package:beez/presentation/map/map_screen.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/register/otp_inserter_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PhoneConfirmationScreen extends StatefulWidget {
  static const String name = 'phone_confirmation';
  final UserModel? userData;
  const PhoneConfirmationScreen({super.key, this.userData});

  @override
  State<PhoneConfirmationScreen> createState() =>
      _PhoneConfirmationScreenState();
}

class _PhoneConfirmationScreenState extends State<PhoneConfirmationScreen> {
  bool processing = false;
  String? currentCode;
  int? resendDurationLeft;

  void submitForm() {
    if (currentCode == null) {
      AppAlerts.error(
          alertContext: context,
          errorMessage: "Insira o código completo, com 6 dígitos");
    } else {
      setState(() {
        processing = true;
      });
      // a.then((user) {
      //   setState(() {
      //     processing = false;
      //   });
      //   GoRouter.of(context).pushNamed(MapScreen.name);
      // }).onError((String errorMsg, _) {
      //   setState(() {
      //     processing = false;
      //   });
      //   AppAlerts.error(alertContext: context, errorMessage: errorMsg);
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Loading(
        isLoading: processing,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Verificação de Telefone",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 40),
                const Text(
                  "OTP Enviado",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Insira o código OTP enviado para o seu telefone",
                  style: TextStyle(
                    color: AppColors.brown,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 15),
                OTPInserter(updateCode: (newCode) {
                  setState(() {
                    currentCode = newCode;
                  });
                }),
                const SizedBox(height: 15),
                RichText(
                  maxLines: 2,
                  text: TextSpan(
                      text: "Não recebeu nenhum código? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                if (resendDurationLeft == null) {
                                  setState(() {
                                    resendDurationLeft = 60;
                                  });
                                  Timer.periodic(const Duration(seconds: 1),
                                      (timer) {
                                    if (resendDurationLeft == 0) {
                                      setState(() {
                                        resendDurationLeft = null;
                                      });
                                      timer.cancel();
                                    } else {
                                      setState(() {
                                        resendDurationLeft =
                                            resendDurationLeft! - 1;
                                      });
                                    }
                                  });
                                }
                              },
                            text:
                                "Reenvie o OTP ${resendDurationLeft != null ? "em ${resendDurationLeft}s" : ''}",
                            style: const TextStyle(color: AppColors.darkYellow))
                      ]),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                    onPressed: submitForm,
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(AppColors.darkYellow),
                    ),
                    child: const Text(
                      "Concluir Cadastro",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          ),
          bottomNavigationBar: const TabNavigation(),
        ),
      ),
    );
  }
}
