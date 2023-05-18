import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_images.dart';
import 'package:beez/presentation/login/login_screen.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/app_field_widget.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/services/auth_service.dart';
import 'package:beez/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String name = 'forgot_password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool processingForm = false;
  String currentEmail = "";

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        processingForm = true;
      });
      _formKey.currentState!.save();
      AuthService.sendPasswordRecovery(currentEmail)
          .whenComplete(() => setState(() {
                processingForm = false;
              }))
          .then((user) {
        AppAlerts.info(
          alertContext: context,
          title: "Redefinição de Senha",
          infoMessage:
              "Um email com o link para a redefinição de senha foi enviado.",
          onCloseAlert: () {
            GoRouter.of(context).pushNamed(LoginScreen.name);
          },
        );
      }).onError((String errorMsg, _) {
        AppAlerts.error(alertContext: context, errorMessage: errorMsg);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Loading(
        isLoading: processingForm,
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Recupere seu acesso à Colmeia!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 15),
                  SvgPicture.asset(
                    AppImages.forgotPasswordBanner,
                    height: 200,
                  ),
                  const SizedBox(height: 30),
                  AppField(
                    child: TextFormField(
                      onSaved: (value) => setState(() {
                        currentEmail = value ?? currentEmail;
                      }),
                      decoration: AppField.inputDecoration(hint: "E-mail"),
                      validator: (value) => value!.validEmail(),
                      style: Theme.of(context).textTheme.bodyMedium!.merge(
                          const TextStyle(decoration: TextDecoration.none)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                      onPressed: submitForm,
                      style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 10)),
                          backgroundColor:
                              MaterialStatePropertyAll(AppColors.darkYellow)),
                      child: const Text(
                        "Recuperar Acesso",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const TabNavigation(),
        ),
      ),
    );
  }
}
